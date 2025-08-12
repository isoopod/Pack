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
	Eval = "V3f24",
	Len = 9,
	Read = function(reader: types.ReaderData): vector
		local x = read_nBitFloat(reader, 7, 16, 0)
		read_moveCursor(reader, 3)

		local y = read_nBitFloat(reader, 7, 16, 0)
		read_moveCursor(reader, 3)

		local z = read_nBitFloat(reader, 7, 16, 0)
		read_moveCursor(reader, 3)

		return vector.create(x, y, z)
	end,
	Write = function(writer: types.WriterData, value: vector)
		write_alloc(writer, 9)

		write_nBitFloat(writer, value.x, 7, 16, 0)
		write_moveCursor(writer, 3)

		write_nBitFloat(writer, value.y, 7, 16, 0)
		write_moveCursor(writer, 3)

		write_nBitFloat(writer, value.z, 7, 16, 0)
		write_moveCursor(writer, 3)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
