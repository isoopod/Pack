--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u16 = Reader.u16
const read_string = Reader.string

const write_string = Writer.string
const write_alloc = Writer.alloc
const write_u16 = Writer.u16

const datatype = table.freeze({
	Eval = "buffer16",
	Len = 2,
	Read = function(reader: types.ReaderData): buffer
		const len = read_u16(reader)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		const s = buffer.tostring(value)
		const len = #s

		write_alloc(writer, len + 2)
		write_u16(writer, len)

		write_string(writer, s, len)
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
