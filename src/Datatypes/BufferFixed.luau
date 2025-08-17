--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_string = Reader.string

local write_alloc = Writer.alloc
local write_stringFixed = Writer.stringFixed

local DEBUG = types.DEBUG

return function(length: number): types.DatatypeInterface<buffer>
	return table.freeze({
		Eval = "buffer",
		Len = length,
		Read = function(reader: types.ReaderData): buffer
			return buffer.fromstring(read_string(reader, length))
		end,
		Write = function(writer: types.WriterData, value: buffer)
			local s = buffer.tostring(value)
			if DEBUG then assert(#s == length, "BufferFixed expects written buffer length (in bytes) to match the allocated length.") end
			write_alloc(writer, length)
			write_stringFixed(writer, s, length)
		end,
	}) :: types.DatatypeInterface<buffer>
end
