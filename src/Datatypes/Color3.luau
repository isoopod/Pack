--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<Color3> = {
	Read = function(Reader: types.Reader): Color3
		return Color3.fromRGB(Reader:u8(), Reader:u8(), Reader:u8())
	end,
	Write = function(Writer: types.Writer, value: Color3)
		Writer:alloc(3)
		Writer:u8(value.R)
		Writer:u8(value.G)
		Writer:u8(value.B)
	end,
}

-- TODO: flag that encodes as f32s for overloaded colors (there are some cases where you have to send a color bigger than 255,255,255)
return datatype
