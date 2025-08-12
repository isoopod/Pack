--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_nBitFloat = Reader.nBitFloat
local read_moveCursor = Reader.moveCursor

local write_alloc = Writer.alloc
local write_nBitFloat = Writer.nBitFloat
local write_moveCursor = Writer.moveCursor

local datatype = table.freeze({
	Eval = "V2f16",
	Len = 4,
	Read = function(reader: types.ReaderData): Vector2
		local x = read_nBitFloat(reader, 5, 10, 0)
		read_moveCursor(reader, 2)

		local y = read_nBitFloat(reader, 5, 10, 0)
		read_moveCursor(reader, 2)

		return Vector2.new(x, y)
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		write_alloc(writer, 4)

		write_nBitFloat(writer, value.X, 5, 10, 0)
		write_moveCursor(writer, 2)

		write_nBitFloat(writer, value.Y, 5, 10, 0)
		write_moveCursor(writer, 2)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
