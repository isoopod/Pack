--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_f64 = Reader.f64

const write_alloc = Writer.alloc
const write_f64 = Writer.f64

const datatype = table.freeze({
	Eval = "f64",
	Len = 8,
	Read = function(reader: types.ReaderData): number
		return read_f64(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 8)
		write_f64(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
