--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function float64
        @within Datatypes
        Represents a 64-bit floating point number ranging from about 1.7e-308 to 1.7e+308.  
		Double is an alias for float64 and can be used in place of it.  
		Numbers in luau are Doubles, though for many applications you do not need that percision and can use a smaller datatype.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:f64()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(8)
		Writer:f64(value)
	end,
}

return datatype
