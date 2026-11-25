--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_i16 = Reader.i16

const write_alloc = Writer.alloc
const write_i16 = Writer.i16

-- Use Vector2 directly, since its nicer to work with
const datatype = table.freeze({
	Eval = "V2i16",
	Len = 4,
	Read = function(reader: types.ReaderData): Vector2int16
		return Vector2int16.new(read_i16(reader), read_i16(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector2int16)
		write_alloc(writer, 4)
		write_i16(writer, value.X)
		write_i16(writer, value.Y)
	end,
}) :: types.DatatypeInterface<Vector2int16>

return datatype
