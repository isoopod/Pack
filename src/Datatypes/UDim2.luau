--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_f32 = Reader.f32
const read_i16 = Reader.i16

const write_alloc = Writer.alloc
const write_f32 = Writer.f32
const write_i16 = Writer.i16

const datatype = table.freeze({
	Eval = "UD2",
	Len = 12,
	Read = function(reader: types.ReaderData): UDim2
		return UDim2.new(read_f32(reader), read_i16(reader), read_f32(reader), read_i16(reader))
	end,
	Write = function(writer: types.WriterData, value: UDim2)
		write_alloc(writer, 12)
		write_f32(writer, value.X.Scale)
		write_i16(writer, value.X.Offset)
		write_f32(writer, value.Y.Scale)
		write_i16(writer, value.Y.Offset)
		-- For the vast majority of applications in Roblox, we can assume the absolute offset will be under
		-- 2^15, letting us get away with 12 bytes instead of 16 (UDim's use an i32 for offset normally)
		-- If greater precision is needed, it is not very hard to make a two Dictionaries with a float32 Scale and an int32 Offset
	end,
}) :: types.DatatypeInterface<UDim2>

return datatype
