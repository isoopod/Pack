--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "Color3",
	Read = function(reader: types.ReaderData): Color3
		return Color3.fromRGB(Reader.u8(reader), Reader.u8(reader), Reader.u8(reader))
	end,
	Write = function(writer: types.WriterData, value: Color3)
		Writer.alloc(writer, 3)
		Writer.u8(writer, value.R * 255)
		Writer.u8(writer, value.G * 255)
		Writer.u8(writer, value.B * 255)
	end,
}) :: types.DatatypeInterface<Color3>

return datatype
