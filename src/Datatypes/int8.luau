--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function int8
        @within Datatypes
        Represents an signed 8-bit integer ranging from -128 to 127.
		Byte is an alias for int8 and can be used in place of it.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:i8()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(1)
		Writer:i8(value)
	end,
}

return datatype
