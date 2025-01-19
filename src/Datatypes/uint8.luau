--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function
        @within Datatypes
        @param valueType: any
        A Pack 'Array' is homogenous, meaning it contains a variable number of items of the same datatype in numeric order.
        You can combine this with other structural datatypes to be able to use multiple datatypes in the array.
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

return function()
	return datatype
end
