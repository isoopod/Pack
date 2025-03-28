--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "V2f24",
	Read = function(reader: types.ReaderData): Vector2
		local x = Reader.nBitFloat(reader, 7, 16, 0)
		Reader.moveCursor(reader, 3)

		local y = Reader.nBitFloat(reader, 7, 16, 0)
		Reader.moveCursor(reader, 3)

		return Vector2.new(x, y)
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		Writer.alloc(writer, 6)

		Writer.nBitFloat(writer, value.X, 7, 16, 0)
		Writer.moveCursor(writer, 3)

		Writer.nBitFloat(writer, value.Y, 7, 16, 0)
		Writer.moveCursor(writer, 3)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
