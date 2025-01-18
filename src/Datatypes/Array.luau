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

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<{ T }>
	local read, write = valueType.Read, valueType.Write

	return {
		Read = function(Reader: types.Reader): T
			local len = Reader:u16()
			local array = table.create(len)

			for _ = 1, len do
				table.insert(array, read(Reader))
			end

			return array
		end,
		Write = function(Writer: types.Writer, value: { T })
			local len = #value
			Writer:alloc(2)
			Writer:u16(len)

			for i = 1, len do
				write(value[i])
			end
		end,
	}
end
