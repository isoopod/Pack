--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_string = Reader.string

const write_alloc = Writer.alloc
const write_string = Writer.string

return function(length: number): types.DatatypeInterface<buffer>
	return table.freeze({
		Eval = "buffer",
		Len = length,
		Read = function(reader: types.ReaderData): buffer
			return buffer.fromstring(read_string(reader, length))
		end,
		Write = function(writer: types.WriterData, value: buffer)
			const s = buffer.tostring(value)
			assert(#s == length, "BufferFixed expects written buffer length to match the allocated length.")

			write_alloc(writer, length)
			write_string(writer, s, length)
		end,
	}) :: types.DatatypeInterface<buffer>
end
