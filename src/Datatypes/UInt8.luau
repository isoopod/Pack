--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u8 = Reader.u8

const write_alloc = Writer.alloc
const write_u8 = Writer.u8

const datatype = table.freeze({
	Eval = "u8",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		return read_u8(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 1)
		write_u8(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
