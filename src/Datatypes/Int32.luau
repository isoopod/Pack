--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_i32 = Reader.i32

const write_alloc = Writer.alloc
const write_i32 = Writer.i32

const datatype = table.freeze({
	Eval = "i32",
	Len = 4,
	Read = function(reader: types.ReaderData): number
		return read_i32(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 4)
		write_i32(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
