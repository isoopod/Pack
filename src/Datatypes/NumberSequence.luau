--!native
--!optimize 2

local BitReader = require(script.Parent.Parent.BitReader)
local BitWriter = require(script.Parent.Parent.BitWriter)
local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local bitr_read = BitReader.read

local bitw_alloc = BitWriter.alloc
local bitw_write = BitWriter.write

local read_u8 = Reader.u8
local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u8 = Writer.u8
local write_u16 = Writer.u16

local DEBUG = types.DEBUG
local PRECISION = 0xffff
local PRECISION_INVERSE = 1 / PRECISION

-- Potential improvement: If there are only two repeated keypoints, only write one.
-- Low priority as that is already a poor use of NumberSequence.

return function(valueType: types.DatatypeInterface<number>): types.DatatypeInterface<NumberSequence>
	local read, write = valueType.Read, valueType.Write

	assert(valueType.Len, "NumberSequence valueType must be a numeric datatype")
	if DEBUG then DEBUG.EnforceDatatype.AnyNumeric(valueType) end

	return table.freeze({
		Eval = "NumberSequence",
		Len = 5 + valueType.len * 2, -- Minimum of 2 keypoints
		Of = valueType,
		Read = function(reader: types.ReaderData): NumberSequence
			local len = read_u8(reader)
			local array = table.create(len) :: { NumberSequenceKeypoint }

			for i = 1, len do
				local time = read_u16(reader) * PRECISION_INVERSE
				local value = read(reader)
				local envelope
				if bitr_read(reader, 1) == 1 then envelope = read(reader) end
				array[i] = NumberSequenceKeypoint.new(time, value, envelope)
			end

			return NumberSequence.new(array)
		end,
		Write = function(writer: types.WriterData, value: NumberSequence)
			local keypoints = value.Keypoints
			local len = #keypoints

			write_alloc(writer, 1 + len * 2) -- Allocate length for the length byte, and all time values
			bitw_alloc(writer, len)

			write_u8(writer, len)

			for i = 1, len do
				local kp = keypoints[i]
				write_u16(writer, kp.Time * PRECISION)
				write(writer, kp.Value)
				local envelope = kp.Envelope
				if envelope ~= 0 then
					bitw_write(writer, 1, 1)
					write(writer, envelope)
				else
					bitw_write(writer, 1, 0)
				end
			end
		end,
	}) :: types.DatatypeInterface<NumberSequence>
end
