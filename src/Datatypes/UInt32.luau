--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u32 = Reader.u32

const write_alloc = Writer.alloc
const write_u32 = Writer.u32

const datatype = table.freeze({
	Eval = "u32",
	Len = 4,
	Read = function(reader: types.ReaderData): number
		return read_u32(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 4)
		write_u32(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
