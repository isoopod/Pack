--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

-- We compress a CFrame's rotational component as a quaternion.
-- Quaternions are compressed to 13 bytes for axis-aligned cases and 19 bytes for non axis-aligned cases.
-- This is significantly better than the axis-angle representation used by ByteNet and Zap, which takes 24 bytes to compress the CFrame.
-- The tradeoff is that compression is more computationally expensive, but easily worth it, especially if these CFrames are sent over the network.

local sin = math.sin
local cos = math.cos
local abs = math.abs
local sqrt = math.sqrt
local floor = math.floor

local lshift = bit32.lshift
local rshift = bit32.rshift
local bor = bit32.bor
local band = bit32.band

local Q90Deg = sqrt(0.5)

local INF = math.huge
local EPSILON = 1e-6
local PRECISION = 0xffff / Q90Deg -- The smaller 3 values in a rotation quaternion fit between [-1/sqrt(2), 1/sqrt(2)]
-- This allows for more percision for the same number of bits

-- Convert a CFrame to a normailised quaternion for encoding
local function cfToNormalisedQuaternion(cf: CFrame): (number, number, number, number)
	local axis, angle = cf:Orthonormalize():ToAxisAngle()

	local d = axis.X * axis.X + axis.Y * axis.Y + axis.Z * axis.Z
	if abs(d) > EPSILON then
		axis *= (1 / sqrt(abs(d)))
	end

	local h = angle / 2
	local s = sin(h)
	axis = axis * s

	local x, y, z, w = axis.X, axis.Y, axis.Z, cos(h)
	d = x * x + y * y + z * z + w * w

	if abs(d) > EPSILON then
		d = sqrt(d)

		return x / d, y / d, z / d, w / d
	end

	return 0, 0, 0, 1 -- identity
end

-- Compress a CFrame as a Quaternion (with 12 axis-aligned rotations and 16-bit rotational components for non-axis-aligned)
local function compressQuaternion(cf: CFrame): (number, number?, number?, number?)
	local qx, qy, qz, qw = cfToNormalisedQuaternion(cf)

	-- Check if the quaternion is axis-aligned and detect the axis and rotation
	local is_x = abs(qx) > 1 - EPSILON
	local is_y = not is_x and abs(qy) > 1 - EPSILON
	local is_z = not is_x and not is_y and abs(qz) > 1 - EPSILON

	if is_x or is_y or is_z then
		-- Axis-aligned quaternion (one of the 12 axis-aligned cases)
		local axis: number, angle: number

		if is_x then
			axis = 0 -- x-axis
			angle = floor(abs(qx) * 3 + 0.5) -- 0°, 90°, 180°, 270° (0-3)
		elseif is_y then
			axis = 1 -- y-axis
			angle = floor(abs(qy) * 3 + 0.5)
		else
			axis = 2 -- z-axis
			angle = floor(abs(qz) * 3 + 0.5)
		end

		-- Return the axis-aligned rotation as a bit packed number (5-17)
		return bor(lshift(axis, 2), angle) + 5, nil, nil, nil
	else
		-- Non axis-aligned quaternion, compress by optimizing out one value and quantizing to 16 bit
		local index = -1
		local value = -INF

		local element: number, v0: number, v1: number, v2: number, val: number, a: number
		for i = 1, 4, 1 do
			val = select(i, qx, qy, qz, qw) :: any
			a = abs(val)
			if a > value then
				index = i
				value = a
				element = val
			end
		end

		if abs(1 - value) < EPSILON then return index + 4, nil, nil, nil end

		local sign = element >= 0 and 1 or -1
		if index == 1 then
			v0 = floor(qy * sign * PRECISION + 0.5)
			v1 = floor(qz * sign * PRECISION + 0.5)
			v2 = floor(qw * sign * PRECISION + 0.5)
		elseif index == 2 then
			v0 = floor(qx * sign * PRECISION + 0.5)
			v1 = floor(qz * sign * PRECISION + 0.5)
			v2 = floor(qw * sign * PRECISION + 0.5)
		elseif index == 3 then
			v0 = floor(qx * sign * PRECISION + 0.5)
			v1 = floor(qy * sign * PRECISION + 0.5)
			v2 = floor(qw * sign * PRECISION + 0.5)
		elseif index == 4 then
			v0 = floor(qx * sign * PRECISION + 0.5)
			v1 = floor(qy * sign * PRECISION + 0.5)
			v2 = floor(qz * sign * PRECISION + 0.5)
		end

		return index, v0, v1, v2
	end
end

-- Decompress a quaternion from either a 12-axis-aligned rotation or a full compressed quaternion
local function decompressQuaternion(qi: number, qa: number?, qb: number?, qc: number?): (number, number, number, number)
	-- If the quaternion is one of the 12 axis-aligned rotations
	if qi >= 5 then
		local combined = qi - 5
		local axis = rshift(combined, 2)
		local angle = band(combined, 0x03)

		-- Initialize the quaternion based on the axis and angle
		local qx, qy, qz, qw = 0, 0, 0, 1 -- Identity quaternion

		if axis == 1 then
			if angle == 0 then
				qx, qw = 1, 0 -- 0° about x-axis
			elseif angle == 1 then
				qx, qw = Q90Deg, Q90Deg -- 90° about x-axis
			elseif angle == 2 then
				qx, qw = 0, 1 -- 180° about x-axis
			elseif angle == 3 then
				qx, qw = -Q90Deg, Q90Deg -- 270° about x-axis
			end
		elseif axis == 2 then
			if angle == 0 then
				qy, qw = 1, 0 -- 0° about y-axis
			elseif angle == 1 then
				qy, qw = Q90Deg, Q90Deg -- 90° about y-axis
			elseif angle == 2 then
				qy, qw = 0, 1 -- 180° about y-axis
			elseif angle == 3 then
				qy, qw = -Q90Deg, Q90Deg -- 270° about y-axis
			end
		elseif axis == 3 then
			if angle == 0 then
				qz, qw = 1, 0 -- 0° about z-axis
			elseif angle == 1 then
				qz, qw = Q90Deg, Q90Deg -- 90° about z-axis
			elseif angle == 2 then
				qz, qw = 0, 1 -- 180° about z-axis
			elseif angle == 3 then
				qz, qw = -Q90Deg, Q90Deg -- 270° about z-axis
			end
		end

		return qw, qx, qy, qz
	else
		-- Non-axis-aligned quaternion, handle the full compression case
		assert(qa and qb and qc, "Non-identity quaternion requires qa, qb, and qc")

		qa /= PRECISION
		qb /= PRECISION
		qc /= PRECISION

		local d = sqrt(1 - (qa * qa + qb * qb + qc * qc))
		if qi == 1 then
			return d, qa, qb, qc
		elseif qi == 2 then
			return qa, d, qb, qc
		elseif qi == 3 then
			return qa, qb, d, qc
		end

		return qa, qb, qc, d
	end
end

local datatype = table.freeze({
	Eval = "CFrame",
	Read = function(Reader: types.Reader): CFrame
		local x = Reader:f32()
		local y = Reader:f32()
		local z = Reader:f32()

		local qx, qy, qz, qw

		local qi = Reader:nBitUint(5, 0)
		if qi > 4 then
			qx, qy, qz, qw = decompressQuaternion(qi)
			Reader:moveCursor(1)
		else
			local qa = Reader:nBitInt(17, 5)
			local qb = Reader:nBitInt(17, 22)
			local qc = Reader:nBitInt(17, 39)
			Reader:moveCursor(7)
			qx, qy, qz, qw = decompressQuaternion(qi, qa, qb, qc)
		end

		return CFrame.new(x, y, z, qx, qy, qz, qw)
	end,
	Write = function(Writer: types.Writer, value: CFrame)
		local x, y, z = value.X, value.Y, value.Z
		local qi, qa, qb, qc = compressQuaternion(value)

		local axisAligned = qi > 4
		Writer:alloc(axisAligned and 13 or 19)

		Writer:f32(x)
		Writer:f32(y)
		Writer:f32(z)

		Writer:nBitUint(qi, 5, 0) -- We have a spare bit here, just using it to optimize out a -1
		if not axisAligned then
			Writer:nBitInt(qa :: number, 17, 5)
			Writer:nBitInt(qb :: number, 17, 22)
			Writer:nBitInt(qc :: number, 17, 39)
			Writer:moveCursor(7)
		else
			Writer:moveCursor(1)
		end
	end,
}) :: types.DatatypeInterface<CFrame>

return datatype
