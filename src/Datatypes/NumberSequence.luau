--!native
--!optimize 2

const BitReader = require(script.Parent.Parent.BitReader)
const BitWriter = require(script.Parent.Parent.BitWriter)
const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const bitr_read = BitReader.read

const bitw_alloc = BitWriter.alloc
const bitw_write = BitWriter.write

const read_u8 = Reader.u8
const read_u16 = Reader.u16

const write_alloc = Writer.alloc
const write_u8 = Writer.u8
const write_u16 = Writer.u16

const DEBUG = types.DEBUG
const PRECISION = 0xffff
const PRECISION_INVERSE = 1 / PRECISION

-- Potential improvement: If there are only two repeated keypoints, only write one.
-- Low priority as that is already a poor use of NumberSequence.

return function(valueType: types.DatatypeInterface<number>): types.DatatypeInterface<NumberSequence>
	const read, write = valueType.Read, valueType.Write

	assert(valueType.Len, "NumberSequence valueType must be a numeric datatype")
	if DEBUG then DEBUG.EnforceDatatype.AnyNumeric(valueType) end

	return table.freeze({
		Eval = "NumberSequence",
		Len = 5 + valueType.len * 2, -- Minimum of 2 keypoints
		Of = valueType,
		Read = function(reader: types.ReaderData): NumberSequence
			const len = read_u8(reader)
			const array = table.create(len) :: { NumberSequenceKeypoint }

			for i = 1, len do
				const time = read_u16(reader) * PRECISION_INVERSE
				const value = read(reader)
				local envelope
				if bitr_read(reader, 1) == 1 then envelope = read(reader) end
				array[i] = NumberSequenceKeypoint.new(time, value, envelope)
			end

			return NumberSequence.new(array)
		end,
		Write = function(writer: types.WriterData, value: NumberSequence)
			const keypoints = value.Keypoints
			const len = #keypoints

			write_alloc(writer, 1 + len * 2) -- Allocate length for the length byte, and all time values
			bitw_alloc(writer, len)

			write_u8(writer, len)

			for i = 1, len do
				const kp = keypoints[i]
				write_u16(writer, kp.Time * PRECISION)
				write(writer, kp.Value)
				const envelope = kp.Envelope
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
