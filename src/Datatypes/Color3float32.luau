--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "Color3Raw",
	Read = function(Reader: types.Reader): Color3
		return Color3.new(Reader:f32(), Reader:f32(), Reader:f32())
	end,
	Write = function(Writer: types.Writer, value: Color3)
		Writer:alloc(12)
		Writer:f32(value.R)
		Writer:f32(value.G)
		Writer:f32(value.B)
	end,
}) :: types.DatatypeInterface<Color3>

return datatype
