--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function boolean
        @within Datatypes
        Represents a boolean value (true or false)

		:::hint
		If you have several boolean values, you can use a Pack 'BitField' instead to fit up to 8 bits per byte.
		:::
]=]

local datatype: types.DatatypeInterface<boolean> = {
	Read = function(Reader: types.Reader): boolean
		return Reader:u8() == 1
	end,
	Write = function(Writer: types.Writer, value: boolean)
		Writer:alloc(1)
		Writer:u8(value and 1 or 0)
	end,
}

return datatype
