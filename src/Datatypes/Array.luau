--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<{ T }>
	local read, write = valueType.Read, valueType.Write

	return table.freeze({
		Eval = "Array",
		Read = function(Reader: types.Reader): { T }
			local len = Reader:u16()
			local array = table.create(len) :: { T }

			for i = 1, len do
				array[i] = read(Reader)
			end

			return array
		end,
		Write = function(Writer: types.Writer, value: { T })
			local len = #value
			Writer:alloc(2)
			Writer:u16(len)

			for i = 1, len do
				write(Writer, value[i])
			end
		end,
	}) :: types.DatatypeInterface<{ T }>
end
