--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function uint32
        @within Datatypes
        Represents an unsigned 32-bit integer ranging from 0 to 4,294,967,296.
		UInt is an alias for uint32 and can be used in place of it.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:u32()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(4)
		Writer:u32(value)
	end,
}

return datatype
