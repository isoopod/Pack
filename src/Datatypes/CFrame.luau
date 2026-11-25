--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_f32 = Reader.f32
const read_nBitUint = Reader.nBitUint
const read_moveCursor = Reader.moveCursor
const read_nBitInt = Reader.nBitInt

const write_alloc = Writer.alloc
const write_f32 = Writer.f32
const write_nBitUint = Writer.nBitUint
const write_nBitInt = Writer.nBitInt
const write_moveCursor = Writer.moveCursor

const CFrame_fromMatrix = CFrame.fromMatrix
const CFrame_new = CFrame.new
const Orthonormalize = CFrame.identity.Orthonormalize
const ToAxisAngle = CFrame.identity.ToAxisAngle

-- We compress a CFrame's rotational component as a quaternion.
-- Quaternions are compressed to 13 bytes for axis-aligned cases and 19 bytes for non axis-aligned cases.
-- This is significantly better than the axis-angle representation used by many libraries, which takes 24 bytes to compress the CFrame.
-- The tradeoff is that quaternion compression is more computationally expensive, but easily it's worth it, especially if these CFrames are sent over the network.

const EPSILON = 1e-6
const PRECISION = 0xffff / math.sqrt(0.5) -- The smaller 3 values in a rotation quaternion fit between [-sqrt(2) / 2, sqrt(2) / 2]
const INV_PRECISION = 1 / PRECISION
-- This allows for more precision for the same number of bits

-- Convert a CFrame to a normalised quaternion for encoding.
const function cfToNormalisedQuaternion(cf: CFrame): (number, number, number, number)
	const axis, angle = ToAxisAngle(Orthonormalize(cf))

	-- Compute scaled axis (axis * sin(angle/2))
	const h = angle * 0.5
	const s = math.sin(h)
	const ax = axis.X * s
	const ay = axis.Y * s
	const az = axis.Z * s
	const w = math.cos(h)

	local d = ax * ax + ay * ay + az * az + w * w

	if d > EPSILON then
		d = 1 / math.sqrt(d)
		return ax * d, ay * d, az * d, w * d
	end

	-- Return identity if magnitude is effectively zero
	return 0, 0, 0, 1
end

-- These freeze calls do not need to be constised despite not having fastcalls since they are only used at runtime
const allowedUpsArray = table.freeze({
	[0] = table.freeze({ 2, 3, 4, 5 }), -- +X -> ±Y, ±Z
	[1] = table.freeze({ 2, 3, 4, 5 }), -- -X -> ±Y, ±Z
	[2] = table.freeze({ 0, 1, 4, 5 }), -- +Y -> ±X, ±Z
	[3] = table.freeze({ 0, 1, 4, 5 }), -- -Y -> ±X, ±Z
	[4] = table.freeze({ 0, 1, 2, 3 }), -- +Z -> ±X, ±Y
	[5] = table.freeze({ 0, 1, 2, 3 }), -- -Z -> ±X, ±Y
})

-- Build an encode map (upIndex -> remappedOrdinal) from the arrays
const allowedUpsEncode: { [number]: { [number]: number } } = {}
for rightIndex, ups in allowedUpsArray do
	const m = table.create(4) :: { [number]: number }
	-- ups is an array of 4 values; map each axis id -> position (1..4)
	for i = 1, #ups do
		const upAxis = ups[i]
		m[upAxis] = i
	end
	allowedUpsEncode[rightIndex] = table.freeze(m)
end
table.freeze(allowedUpsEncode)

-- stylua: ignore
const axisLUT = table.freeze({
	[Vector3.xAxis] = 0, [-Vector3.xAxis] = 1,
	[Vector3.yAxis] = 2, [-Vector3.yAxis] = 3,
	[Vector3.zAxis] = 4, [-Vector3.zAxis] = 5,
})

-- Compress a CFrame as a Quaternion (with 24 axis-aligned rotations and 16-bit rotational components for non-axis-aligned)
const function compressQuaternion(cf: CFrame): (number, number?, number?, number?)
	const right, up = cf.XVector, cf.YVector

	-- Determine Right and Up indices
	const rightIndex = axisLUT[right]
	const upIndexRaw = rightIndex and axisLUT[up]

	if rightIndex and upIndexRaw then
		const validUpIndex = allowedUpsEncode[rightIndex][upIndexRaw] -- direct O(1) lookup
		if validUpIndex then return 5 + (rightIndex * 4) + (validUpIndex - 1), nil, nil, nil end
	end

	-- Non axis-aligned quaternion, compress by optimizing out one value and quantizing to 16 bit
	const qx, qy, qz, qw = cfToNormalisedQuaternion(cf)

	-- Find largest absolute component (explicit comparisons)
	const ax = qx >= 0 and qx or -qx
	const ay = qy >= 0 and qy or -qy
	const az = qz >= 0 and qz or -qz
	const aw = qw >= 0 and qw or -qw

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

	const sign = element >= 0 and 1 or -1
	if index == 1 then
		v0 = (qy * sign * PRECISION + 0.5) // 1
		v1 = (qz * sign * PRECISION + 0.5) // 1
		v2 = (qw * sign * PRECISION + 0.5) // 1
	elseif index == 2 then
		v0 = (qx * sign * PRECISION + 0.5) // 1
		v1 = (qz * sign * PRECISION + 0.5) // 1
		v2 = (qw * sign * PRECISION + 0.5) // 1
	elseif index == 3 then
		v0 = (qx * sign * PRECISION + 0.5) // 1
		v1 = (qy * sign * PRECISION + 0.5) // 1
		v2 = (qw * sign * PRECISION + 0.5) // 1
	elseif index == 4 then
		v0 = (qx * sign * PRECISION + 0.5) // 1
		v1 = (qy * sign * PRECISION + 0.5) // 1
		v2 = (qz * sign * PRECISION + 0.5) // 1
	end

	return index, v0, v1, v2
end

-- stylua: ignore
const axisVectors = {
	Vector3.xAxis, -Vector3.xAxis,
	Vector3.yAxis, -Vector3.yAxis,
	Vector3.zAxis, -Vector3.zAxis,
}

const function decompressAxisAligned(qi: number, x: number, y: number, z: number): CFrame
	-- Decode Right and Up indices
	const encoding = qi - 5
	const rightIndex = encoding // 4
	const upIndexRemapped = encoding % 4

	-- Look up the actual up axis code using the allowedUps table:
	const actualUpAxis = allowedUpsArray[rightIndex][upIndexRemapped + 1]

	const right = axisVectors[rightIndex + 1]
	const up = axisVectors[actualUpAxis + 1]

	return CFrame_fromMatrix(vector.create(x, y, z) :: any, right :: any, up :: any)
end

const function decompressQuaternion(qi: number, qa: number?, qb: number?, qc: number?): (number, number, number, number)
	-- Non-axis-aligned quaternion, handle the full compression case
	assert(qa and qb and qc, "Non-identity quaternion requires qa, qb, and qc")

	qa *= INV_PRECISION
	qb *= INV_PRECISION
	qc *= INV_PRECISION

	const sum = (qa * qa + qb * qb + qc * qc)
	const d = math.sqrt(1 - sum)
	if qi == 1 then
		return d, qa, qb, qc
	elseif qi == 2 then
		return qa, d, qb, qc
	elseif qi == 3 then
		return qa, qb, d, qc
	end

	return qa, qb, qc, d
end

const datatype = table.freeze({
	Eval = "CFrame",
	Len = 19, -- We will use the 19 byte size here as it is more likely
	Read = function(reader: types.ReaderData): CFrame
		const rf32 = read_f32
		const x = rf32(reader)
		const y = rf32(reader)
		const z = rf32(reader)

		const qi = read_nBitUint(reader, 5, 0)
		if qi > 4 then
			read_moveCursor(reader, 1)
			-- cframe must be captured in a register before returning to allow inlining
			const cframe = decompressAxisAligned(qi, x, y, z)
			return cframe
		else
			const rnbi = read_nBitInt
			const qa = rnbi(reader, 17, 5)
			const qb = rnbi(reader, 17, 22)
			const qc = rnbi(reader, 17, 39)
			read_moveCursor(reader, 7)

			const qx, qy, qz, qw = decompressQuaternion(qi, qa, qb, qc)
			return CFrame_new(x, y, z, qx, qy, qz, qw)
		end
	end,
	Write = function(writer: types.WriterData, value: CFrame)
		const x, y, z = value.X, value.Y, value.Z
		const qi, qa, qb, qc = compressQuaternion(value)

		const axisAligned = qi > 4
		write_alloc(writer, axisAligned and 13 or 19)

		const wf32 = write_f32
		wf32(writer, x)
		wf32(writer, y)
		wf32(writer, z)

		write_nBitUint(writer, qi, 5, 0)
		if not axisAligned then
			const wnbi = write_nBitInt
			wnbi(writer, qa :: number, 17, 5)
			wnbi(writer, qb :: number, 17, 22)
			wnbi(writer, qc :: number, 17, 39)
			write_moveCursor(writer, 7)
		else
			write_moveCursor(writer, 1)
		end
	end,
}) :: types.DatatypeInterface<CFrame>

return datatype
