--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u32 = Reader.u32
const read_string = Reader.string

const write_string = Writer.string
const write_alloc = Writer.alloc
const write_u32 = Writer.u32

const datatype = table.freeze({
	Eval = "s32",
	Len = 4,
	Read = function(reader: types.ReaderData): string
		const len = read_u32(reader)
		return read_string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		const len = #value

		write_alloc(writer, len + 4)
		write_u32(writer, len)

		write_string(writer, value, len)
	end,
}) :: types.DatatypeInterface<string>

return datatype
