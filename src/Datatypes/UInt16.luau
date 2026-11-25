--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u16 = Reader.u16

const write_alloc = Writer.alloc
const write_u16 = Writer.u16

const datatype = table.freeze({
	Eval = "u16",
	Len = 2,
	Read = function(reader: types.ReaderData): number
		return read_u16(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 2)
		write_u16(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
