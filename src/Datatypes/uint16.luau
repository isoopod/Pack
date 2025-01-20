--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function uint16
        @within Datatypes
        Represents an unsigned 16-bit integer ranging from 0 to 65,536.
		UShort is an alias for uint16 and can be used in place of it.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:u16()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(2)
		Writer:u16(value)
	end,
}

return datatype
