--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_f32 = Reader.f32

const write_alloc = Writer.alloc
const write_f32 = Writer.f32

const datatype = table.freeze({
	Eval = "f32",
	Len = 4,
	Read = function(reader: types.ReaderData): number
		return read_f32(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 4)
		write_f32(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
