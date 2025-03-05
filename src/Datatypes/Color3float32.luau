--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "Color3Raw",
	Read = function(reader: types.ReaderData): Color3
		return Color3.new(Reader.f32(reader), Reader.f32(reader), Reader.f32(reader))
	end,
	Write = function(writer: types.WriterData, value: Color3)
		Writer.alloc(writer, 12)
		Writer.f32(writer, value.R)
		Writer.f32(writer, value.G)
		Writer.f32(writer, value.B)
	end,
}) :: types.DatatypeInterface<Color3>

return datatype
