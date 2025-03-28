--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "f16",
	Read = function(reader: types.ReaderData): number
		local value = Reader.nBitFloat(reader, 7, 16, 0)
		Reader.moveCursor(reader, 3)
		return value
	end,
	Write = function(writer: types.WriterData, value: number)
		Writer.alloc(writer, 3)

		Writer.nBitFloat(writer, value, 7, 16, 0)
		Writer.moveCursor(writer, 3)
	end,
}) :: types.DatatypeInterface<number>

return datatype
