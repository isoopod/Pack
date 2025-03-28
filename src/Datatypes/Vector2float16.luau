--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "V2f16",
	Read = function(reader: types.ReaderData): Vector2
		local x = Reader.nBitFloat(reader, 5, 10, 0)
		Reader.moveCursor(reader, 2)

		local y = Reader.nBitFloat(reader, 5, 10, 0)
		Reader.moveCursor(reader, 2)

		return Vector2.new(x, y)
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		Writer.alloc(writer, 4)

		Writer.nBitFloat(writer, value.X, 5, 10, 0)
		Writer.moveCursor(writer, 2)

		Writer.nBitFloat(writer, value.Y, 5, 10, 0)
		Writer.moveCursor(writer, 2)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
