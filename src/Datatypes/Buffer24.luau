--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "buffer32",
	Read = function(reader: types.ReaderData): buffer
		local len = Reader.nBitUint(reader, 24, 0)
		Reader.moveCursor(reader, 3)
		return buffer.fromstring(Reader.string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local len, write = Writer.string(writer, buffer.tostring(value))

		Writer.alloc(writer, 3)
		Writer.nBitUint(writer, len, 24, 0)
		Writer.moveCursor(writer, 3)

		write()
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
