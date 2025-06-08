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
	Eval = "V3f16",
	Read = function(reader: types.ReaderData): vector
		local x = read_nBitFloat(reader, 5, 10, 0)
		read_moveCursor(reader, 2)

		local y = read_nBitFloat(reader, 5, 10, 0)
		read_moveCursor(reader, 2)

		local z = read_nBitFloat(reader, 5, 10, 0)
		read_moveCursor(reader, 2)

		return vector.create(x, y, z)
	end,
	Write = function(writer: types.WriterData, value: vector)
		write_alloc(writer, 6)

		write_nBitFloat(writer, value.x, 5, 10, 0)
		write_moveCursor(writer, 2)

		write_nBitFloat(writer, value.y, 5, 10, 0)
		write_moveCursor(writer, 2)

		write_nBitFloat(writer, value.z, 5, 10, 0)
		write_moveCursor(writer, 2)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
