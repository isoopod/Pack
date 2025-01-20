--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function float32
        @within Datatypes
        Represents a 32-bit floating point number ranging from about 3.4e-38 to 3.4e+38.
		Float is an alias for float32 and can be used in place of it.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:f32()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(4)
		Writer:f32(value)
	end,
}

return datatype
