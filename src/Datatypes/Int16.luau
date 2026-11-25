--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_i16 = Reader.i16

const write_alloc = Writer.alloc
const write_i16 = Writer.i16

const datatype = table.freeze({
	Eval = "i16",
	Len = 2,
	Read = function(reader: types.ReaderData): number
		return read_i16(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 2)
		write_i16(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
