--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function int16
        @within Datatypes
        Represents an signed 16-bit integer ranging from -32,768 to 32,767.
		Short is an alias for int16 and can be used in place of it.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:i16()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(2)
		Writer:i16(value)
	end,
}

return datatype
