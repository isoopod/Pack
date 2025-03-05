--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

-- Use Vector2 directly, since its nicer to work with
local datatype = table.freeze({
	Eval = "V2i16",
	Read = function(reader: types.ReaderData): Vector2
		return Vector2.new(Reader.i16(reader), Reader.i16(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		Writer.alloc(writer, 4)
		Writer.i16(writer, value.X)
		Writer.i16(writer, value.Y)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
