--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

return function(format: { [any]: types.DatatypeInterface<any> }): types.DatatypeInterface<{}>
	-- In order to make it so we can read and write a dictionary in the same order, we will
	-- take all the provided elements, and assign them with an index based on table.sort
	local len = 0
	for _ in format do
		len += 1
	end

	local structure = table.create(len) :: { any }

	for k in format do
		table.insert(structure, k)
	end

	table.sort(structure)

	return table.freeze({
		Eval = "Dict",
		Read = function(Reader: types.Reader)
			local result = {}

			for i = 1, len do
				local key = structure[i]
				result[key] = format[key].Read(Reader)
			end

			return result
		end,
		Write = function(Writer: types.Writer, value: { [any]: types.DatatypeInterface<any> })
			for i = 1, len do
				local key = structure[i]
				format[key].Write(Writer, value[key])
			end
		end,
	}) :: types.DatatypeInterface<{}>
end
