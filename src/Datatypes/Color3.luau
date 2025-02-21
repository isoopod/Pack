--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "Color3",
	Read = function(Reader: types.Reader): Color3
		return Color3.fromRGB(Reader:u8(), Reader:u8(), Reader:u8())
	end,
	Write = function(Writer: types.Writer, value: Color3)
		Writer:alloc(3)
		Writer:u8(value.R * 255)
		Writer:u8(value.G * 255)
		Writer:u8(value.B * 255)
	end,
}) :: types.DatatypeInterface<Color3>

return datatype
