--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_nBitFloat = Reader.nBitFloat
local read_moveCursor = Reader.moveCursor

local write_alloc = Writer.alloc
local write_nBitFloat = Writer.nBitFloat
local write_moveCursor = Writer.moveCursor

local datatype = table.freeze({
	Eval = "V2f24",
	Read = function(reader: types.ReaderData): Vector2
		local x = read_nBitFloat(reader, 7, 16, 0)
		read_moveCursor(reader, 3)

		local y = read_nBitFloat(reader, 7, 16, 0)
		read_moveCursor(reader, 3)

		return Vector2.new(x, y)
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		write_alloc(writer, 6)

		write_nBitFloat(writer, value.X, 7, 16, 0)
		write_moveCursor(writer, 3)

		write_nBitFloat(writer, value.Y, 7, 16, 0)
		write_moveCursor(writer, 3)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
