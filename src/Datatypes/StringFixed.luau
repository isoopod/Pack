--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_string = Reader.string

const write_alloc = Writer.alloc
const write_string = Writer.string

return function(length: number): types.DatatypeInterface<string>
	return table.freeze({
		Eval = "string",
		Len = length,
		Read = function(reader: types.ReaderData): string
			return read_string(reader, length)
		end,
		Write = function(writer: types.WriterData, value: string)
			assert(#value == length, "stringFixed expects written string length (in bytes) to match the allocated length.")
			write_alloc(writer, length)
			write_string(writer, value, length)
		end,
	}) :: types.DatatypeInterface<string>
end
