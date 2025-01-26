--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

-- Use Vector2 directly, since its nicer to work with
local datatype: types.DatatypeInterface<Vector2> = {
	Read = function(Reader: types.Reader): Vector2
		return Vector2.new(Reader:i16(), Reader:i16())
	end,
	Write = function(Writer: types.Writer, value: Vector2)
		Writer:alloc(4)
		Writer:i16(value.X)
		Writer:i16(value.Y)
	end,
}

return datatype
