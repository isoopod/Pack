--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

return function(format: { [string]: types.DatatypeInterface<any> }): types.DatatypeInterface<{}>
	-- In order to make it so we can read and write a dictionary in the same order, we will take all the provided elements, and assign them with an index alphanumerically
	local len = 0
	for _ in format do
		len += 1
	end

	local order = table.create(len) :: { string }

	for k in format do
		table.insert(order, k)
	end

	table.sort(order)

	return {
		Read = function(Reader: types.Reader)
			local result = {}

			for i = 1, len do
				local key = order[i]
				result[key] = format[key].Read(Reader)
			end

			return result
		end,
		Write = function(Writer: types.Writer, value: { [string]: types.DatatypeInterface<any> })
			for i = 1, len do
				local key = order[i]
				format[key].Write(Writer, value[key])
			end
		end,
	} :: any
end
