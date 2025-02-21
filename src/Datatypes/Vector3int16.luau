--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

-- We are going to and from the vector class here, as the Vector3int16 is very slow in comparison.
local datatype = table.freeze({
	Eval = "V3i16",
	Read = function(Reader: types.Reader): vector
		return vector.create(Reader:i16(), Reader:i16(), Reader:i16())
	end,
	Write = function(Writer: types.Writer, value: vector)
		Writer:alloc(6)
		Writer:i16(value.x)
		Writer:i16(value.y)
		Writer:i16(value.z)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
