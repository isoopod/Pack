--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_i16 = Reader.i16

const write_alloc = Writer.alloc
const write_i16 = Writer.i16

const datatype = table.freeze({
	Eval = "R3i16",
	Len = 12,
	Read = function(reader: types.ReaderData): Region3int16
		const min = Vector3int16.new(read_i16(reader), read_i16(reader), read_i16(reader))
		const max = Vector3int16.new(read_i16(reader), read_i16(reader), read_i16(reader))

		return Region3int16.new(min, max)
	end,
	Write = function(writer: types.WriterData, value: Region3int16)
		const min = value.Min
		const max = value.Max

		write_alloc(writer, 12)
		write_i16(writer, min.X)
		write_i16(writer, min.Y)
		write_i16(writer, min.Z)
		write_i16(writer, max.X)
		write_i16(writer, max.Y)
		write_i16(writer, max.Z)
	end,
}) :: types.DatatypeInterface<Region3int16>

return datatype
