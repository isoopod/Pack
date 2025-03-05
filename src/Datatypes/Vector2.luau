--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "V2",
	Read = function(reader: types.ReaderData): Vector2
		return Vector2.new(Reader.f32(reader), Reader.f32(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		Writer.alloc(writer, 8)
		Writer.f32(writer, value.X)
		Writer.f32(writer, value.Y)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
