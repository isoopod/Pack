--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_nBitUint = Reader.nBitUint
const read_moveCursor = Reader.moveCursor
const read_string = Reader.string

const write_string = Writer.string
const write_alloc = Writer.alloc
const write_nBitUint = Writer.nBitUint
const write_moveCursor = Writer.moveCursor

const datatype = table.freeze({
	Eval = "buffer24",
	Len = 3,
	Read = function(reader: types.ReaderData): buffer
		const len = read_nBitUint(reader, 24, 0)
		read_moveCursor(reader, 3)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		const s = buffer.tostring(value)
		const len = #s

		write_alloc(writer, len + 3)
		write_nBitUint(writer, len, 24, 0)
		write_moveCursor(writer, 3)

		write_string(writer, s, len)
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
