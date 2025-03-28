--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "f16",
	Read = function(reader: types.ReaderData): number
		local value = Reader.nBitFloat(reader, 5, 10, 0)
		Reader.moveCursor(reader, 2)
		return value
	end,
	Write = function(writer: types.WriterData, value: number)
		Writer.alloc(writer, 2)

		Writer.nBitFloat(writer, value, 5, 10, 0)
		Writer.moveCursor(writer, 2)
	end,
}) :: types.DatatypeInterface<number>

return datatype
