--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function uint8
        @within Datatypes
        Represents an unsigned 8-bit integer ranging from 0 to 255.
		UByte is an alias for uint8 and can be used in place of it.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:u8()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(1)
		Writer:u8(value)
	end,
}

return datatype
