--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_nBitFloat = Reader.nBitFloat
const read_moveCursor = Reader.moveCursor

const write_alloc = Writer.alloc
const write_nBitFloat = Writer.nBitFloat
const write_moveCursor = Writer.moveCursor

const datatype = table.freeze({
	Eval = "f24",
	Len = 3,
	Read = function(reader: types.ReaderData): number
		const value = read_nBitFloat(reader, 7, 16, 0)
		read_moveCursor(reader, 3)
		return value
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 3)

		write_nBitFloat(writer, value, 7, 16, 0)
		write_moveCursor(writer, 3)
	end,
}) :: types.DatatypeInterface<number>

return datatype
