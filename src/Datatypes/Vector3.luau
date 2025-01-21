--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<vector> = {
	Read = function(Reader: types.Reader): vector
		return vector.create(Reader:f32(), Reader:f32(), Reader:f32())
	end,
	Write = function(Writer: types.Writer, value: vector)
		Writer:alloc(12)
		Writer:f32(value.x)
		Writer:f32(value.y)
		Writer:f32(value.z)
	end,
}

return datatype
