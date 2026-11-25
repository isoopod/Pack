--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u8 = Reader.u8
const read_string = Reader.string

const write_string = Writer.string
const write_alloc = Writer.alloc
const write_u8 = Writer.u8

const datatype = table.freeze({
	Eval = "buffer8",
	Len = 1,
	Read = function(reader: types.ReaderData): buffer
		const len = read_u8(reader)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		const s = buffer.tostring(value)
		const len = #s

		write_alloc(writer, len + 1)
		write_u8(writer, len)

		write_string(writer, s, len)
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
