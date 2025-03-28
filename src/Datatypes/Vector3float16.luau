--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "V3f16",
	Read = function(reader: types.ReaderData): vector
		local x = Reader.nBitFloat(reader, 5, 10, 0)
		Reader.moveCursor(reader, 2)

		local y = Reader.nBitFloat(reader, 5, 10, 0)
		Reader.moveCursor(reader, 2)

		local z = Reader.nBitFloat(reader, 5, 10, 0)
		Reader.moveCursor(reader, 2)

		return vector.create(x, y, z)
	end,
	Write = function(writer: types.WriterData, value: vector)
		Writer.alloc(writer, 6)

		Writer.nBitFloat(writer, value.x, 5, 10, 0)
		Writer.moveCursor(writer, 2)

		Writer.nBitFloat(writer, value.y, 5, 10, 0)
		Writer.moveCursor(writer, 2)

		Writer.nBitFloat(writer, value.z, 5, 10, 0)
		Writer.moveCursor(writer, 2)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
