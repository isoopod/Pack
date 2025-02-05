--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<UDim> = {
	Read = function(Reader: types.Reader): UDim
		return UDim.new(Reader:f32(), Reader:i16())
	end,
	Write = function(Writer: types.Writer, value: UDim)
		Writer:alloc(6)
		Writer:f32(value.Scale)
		Writer:i16(value.Offset)
		-- For the vast majority of applications in Roblox, we can assume the absolute offset will be under
		-- 2^15, letting us get away with 6 bytes instead of 8 (UDim's use an i32 for offset normally)
		-- If greater percision is needed, it is not very hard to make a Dictionary with a float32 Scale and an int32 Offset
	end,
}

return datatype
