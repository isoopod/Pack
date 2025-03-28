--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "V3f24",
	Read = function(reader: types.ReaderData): vector
		local x = Reader.nBitFloat(reader, 7, 16, 0)
		Reader.moveCursor(reader, 3)

		local y = Reader.nBitFloat(reader, 7, 16, 0)
		Reader.moveCursor(reader, 3)

		local z = Reader.nBitFloat(reader, 7, 16, 0)
		Reader.moveCursor(reader, 3)

		return vector.create(x, y, z)
	end,
	Write = function(writer: types.WriterData, value: vector)
		Writer.alloc(writer, 9)

		Writer.nBitFloat(writer, value.x, 7, 16, 0)
		Writer.moveCursor(writer, 3)

		Writer.nBitFloat(writer, value.y, 7, 16, 0)
		Writer.moveCursor(writer, 3)

		Writer.nBitFloat(writer, value.z, 7, 16, 0)
		Writer.moveCursor(writer, 3)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
