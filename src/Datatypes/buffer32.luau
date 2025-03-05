--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "buffer32",
	Read = function(reader: types.ReaderData): buffer
		local len = Reader.u32(reader)
		return buffer.fromstring(Reader.string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local len, write = Writer.string(writer, buffer.tostring(value))

		Writer.alloc(writer, 4)
		Writer.u32(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
