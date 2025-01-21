--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<Vector2> = {
	Read = function(Reader: types.Reader): Vector2
		return Vector2.new(Reader:f32(), Reader:f32())
	end,
	Write = function(Writer: types.Writer, value: Vector2)
		Writer:alloc(8)
		Writer:f32(value.X)
		Writer:f32(value.Y)
	end,
}

return datatype
