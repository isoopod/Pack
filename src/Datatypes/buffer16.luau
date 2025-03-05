--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "buffer16",
	Read = function(reader: types.ReaderData): buffer
		local len = Reader.u16(reader)
		return buffer.fromstring(Reader.string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local len, write = Writer.string(writer, buffer.tostring(value))

		Writer.alloc(writer, 2)
		Writer.u16(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
