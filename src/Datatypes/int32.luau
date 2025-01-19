--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function int32
        @within Datatypes
        Represents an signed 32-bit integer ranging from -2,147,483,648 to 2,147,483,647.
		Int is an alias for int32 and can be used in place of it.
]=]

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:i32()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(4)
		Writer:i32(value)
	end,
}

return function()
	return datatype
end
