--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_i16 = Reader.i16

const write_alloc = Writer.alloc
const write_i16 = Writer.i16

-- We are going to and from the vector class here, as the Vector3int16 is very slow in comparison.
const datatype = table.freeze({
	Eval = "V3i16",
	Len = 6,
	Read = function(reader: types.ReaderData): Vector3int16
		return Vector3int16.new(read_i16(reader), read_i16(reader), read_i16(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector3int16)
		write_alloc(writer, 6)
		write_i16(writer, value.X)
		write_i16(writer, value.Y)
		write_i16(writer, value.Z)
	end,
}) :: types.DatatypeInterface<Vector3int16>

return datatype
