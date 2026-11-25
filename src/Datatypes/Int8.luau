--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_i8 = Reader.i8

const write_alloc = Writer.alloc
const write_i8 = Writer.i8

const datatype = table.freeze({
	Eval = "i8",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		return read_i8(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 1)
		write_i8(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
