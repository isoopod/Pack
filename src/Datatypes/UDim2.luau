--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "UD2",
	Read = function(Reader: types.Reader): UDim2
		return UDim2.new(Reader:f32(), Reader:i16(), Reader:f32(), Reader:i16())
	end,
	Write = function(Writer: types.Writer, value: UDim2)
		Writer:alloc(12)
		Writer:f32(value.X.Scale)
		Writer:i16(value.X.Offset)
		Writer:f32(value.Y.Scale)
		Writer:i16(value.Y.Offset)
		-- For the vast majority of applications in Roblox, we can assume the absolute offset will be under
		-- 2^15, letting us get away with 12 bytes instead of 16 (UDim's use an i32 for offset normally)
		-- If greater percision is needed, it is not very hard to make a two Dictionaries with a float32 Scale and an int32 Offset
	end,
}) :: types.DatatypeInterface<UDim2>

return datatype
