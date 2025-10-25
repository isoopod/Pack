--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_f32 = Reader.f32
local read_nBitUint = Reader.nBitUint
local read_moveCursor = Reader.moveCursor
local read_nBitInt = Reader.nBitInt

local write_alloc = Writer.alloc
local write_f32 = Writer.f32
local write_nBitUint = Writer.nBitUint
local write_nBitInt = Writer.nBitInt
local write_moveCursor = Writer.moveCursor

-- We compress a CFrame's rotational component as a quaternion.
-- Quaternions are compressed to 13 bytes for axis-aligned cases and 19 bytes for non axis-aligned cases.
-- This is significantly better than the axis-angle representation used by many libraries, which takes 24 bytes to compress the CFrame.
-- The tradeoff is that quaternion compression is more computationally expensive, but easily it's worth it, especially if these CFrames are sent over the network.

local EPSILON = 1e-6
local PRECISION = 0xffff / math.sqrt(0.5) -- The smaller 3 values in a rotation quaternion fit between [-sqrt(2) / 2, sqrt(2) / 2]
-- This allows for more precision for the same number of bits

-- Convert a CFrame to a normalised quaternion for encoding.
local function cfToNormalisedQuaternion(cf: CFrame): (number, number, number, number)
	local axis, angle = cf:Orthonormalize():ToAxisAngle()

	-- Compute scaled axis (axis * sin(angle/2))
	local h = angle * 0.5
	local s = math.sin(h)
	local ax = axis.X * s
	local ay = axis.Y * s
	local az = axis.Z * s
	local w = math.cos(h)

	local d = ax * ax + ay * ay + az * az + w * w

	if math.abs(d) > EPSILON then
		d = math.sqrt(d)
		return ax / d, ay / d, az / d, w / d
	end

	-- Return identity if magnitude is effectively zero
	return 0, 0, 0, 1
end

local allowedUps = table.freeze({
	[0] = { [2] = 1, [3] = 2, [4] = 3, [5] = 4 },
	[1] = { [2] = 1, [3] = 2, [4] = 3, [5] = 4 },
	[2] = { [0] = 1, [1] = 2, [4] = 3, [5] = 4 },
	[3] = { [0] = 1, [1] = 2, [4] = 3, [5] = 4 },
	[4] = { [0] = 1, [1] = 2, [2] = 3, [3] = 4 },
	[5] = { [0] = 1, [1] = 2, [2] = 3, [3] = 4 },
})
-- stylua: ignore
local axisLUT = table.freeze({
	[Vector3.xAxis] = 0, [-Vector3.xAxis] = 1,
	[Vector3.yAxis] = 2, [-Vector3.yAxis] = 3,
	[Vector3.zAxis] = 4, [-Vector3.zAxis] = 5,
})

-- Compress a CFrame as a Quaternion (with 24 axis-aligned rotations and 16-bit rotational components for non-axis-aligned)
local function compressQuaternion(cf: CFrame): (number, number?, number?, number?)
	local round = math.round
	local right, up = cf.XVector, cf.YVector

	-- Determine Right and Up indices
	local rightIndex = axisLUT[right]
	local upIndexRaw = rightIndex and axisLUT[up]

	if rightIndex and upIndexRaw then
		local validUpIndex = allowedUps[rightIndex][upIndexRaw] -- direct O(1) lookup
		if validUpIndex then return 5 + (rightIndex * 4) + (validUpIndex - 1), nil, nil, nil end
	end

	-- Non axis-aligned quaternion, compress by optimizing out one value and quantizing to 16 bit
	local qx, qy, qz, qw = cfToNormalisedQuaternion(cf)

	-- Find largest absolute component (explicit comparisons)
	local ax = qx >= 0 and qx or -qx
	local ay = qy >= 0 and qy or -qy
	local az = qz >= 0 and qz or -qz
	local aw = qw >= 0 and qw or -qw

	local index = 1
	local value = ax
	local element = qx
	local v0: number, v1: number, v2: number

	if ay > value then
		index, value, element = 2, ay, qy
	end
	if az > value then
		index, value, element = 3, az, qz
	end
	if aw > value then
		index, value, element = 4, aw, qw
	end

	local sign = element >= 0 and 1 or -1
	if index == 1 then
		v0 = round(qy * sign * PRECISION)
		v1 = round(qz * sign * PRECISION)
		v2 = round(qw * sign * PRECISION)
	elseif index == 2 then
		v0 = round(qx * sign * PRECISION)
		v1 = round(qz * sign * PRECISION)
		v2 = round(qw * sign * PRECISION)
	elseif index == 3 then
		v0 = round(qx * sign * PRECISION)
		v1 = round(qy * sign * PRECISION)
		v2 = round(qw * sign * PRECISION)
	elseif index == 4 then
		v0 = round(qx * sign * PRECISION)
		v1 = round(qy * sign * PRECISION)
		v2 = round(qz * sign * PRECISION)
	end

	return index, v0, v1, v2
end

-- stylua: ignore
local axisVectors = {
	Vector3.xAxis, -Vector3.xAxis,
	Vector3.yAxis, -Vector3.yAxis,
	Vector3.zAxis, -Vector3.zAxis,
}

local function decompressAxisAligned(qi: number, x: number, y: number, z: number): CFrame
	-- Decode Right and Up indices
	local encoding = qi - 5
	local rightIndex = encoding // 4
	local upIndexRemapped = encoding % 4

	-- Look up the actual up axis code using the allowedUps table:
	local actualUpAxis = allowedUps[rightIndex][upIndexRemapped + 1]

	local right = axisVectors[rightIndex + 1]
	local up = axisVectors[actualUpAxis + 1]

	return CFrame.fromMatrix(vector.create(x, y, z) :: any, right :: any, up :: any)
end

local function decompressQuaternion(qi: number, qa: number?, qb: number?, qc: number?): (number, number, number, number)
	-- Non-axis-aligned quaternion, handle the full compression case
	assert(qa and qb and qc, "Non-identity quaternion requires qa, qb, and qc")

	qa /= PRECISION
	qb /= PRECISION
	qc /= PRECISION

	local d = math.sqrt(1 - (qa * qa + qb * qb + qc * qc))
	if qi == 1 then
		return d, qa, qb, qc
	elseif qi == 2 then
		return qa, d, qb, qc
	elseif qi == 3 then
		return qa, qb, d, qc
	end

	return qa, qb, qc, d
end

local datatype = table.freeze({
	Eval = "CFrame",
	Len = 19, -- We will use the 19 byte size here as it is more likely
	Read = function(reader: types.ReaderData): CFrame
		local x = read_f32(reader)
		local y = read_f32(reader)
		local z = read_f32(reader)

		local qx: number, qy: number, qz: number, qw: number

		local qi = read_nBitUint(reader, 5, 0)
		if qi > 4 then
			read_moveCursor(reader, 1)
			return decompressAxisAligned(qi, x, y, z)
		else
			local qa = read_nBitInt(reader, 17, 5)
			local qb = read_nBitInt(reader, 17, 22)
			local qc = read_nBitInt(reader, 17, 39)
			read_moveCursor(reader, 7)
			qx, qy, qz, qw = decompressQuaternion(qi, qa, qb, qc)
		end

		return CFrame.new(x, y, z, qx, qy, qz, qw)
	end,
	Write = function(writer: types.WriterData, value: CFrame)
		local x, y, z = value.X, value.Y, value.Z
		local qi, qa, qb, qc = compressQuaternion(value)

		local axisAligned = qi > 4
		write_alloc(writer, axisAligned and 13 or 19)

		write_f32(writer, x)
		write_f32(writer, y)
		write_f32(writer, z)

		write_nBitUint(writer, qi, 5, 0)
		if not axisAligned then
			write_nBitInt(writer, qa :: number, 17, 5)
			write_nBitInt(writer, qb :: number, 17, 22)
			write_nBitInt(writer, qc :: number, 17, 39)
			write_moveCursor(writer, 7)
		else
			write_moveCursor(writer, 1)
		end
	end,
}) :: types.DatatypeInterface<CFrame>

return datatype
