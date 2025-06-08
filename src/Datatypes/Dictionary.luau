--!strict
--!native
--!optimize 2

local types = require("../types")

return function(format: { [any]: types.DatatypeInterface<any> }): types.DatatypeInterface<{}>
	-- In order to make it so we can read and write a dictionary in the same order, we will
	-- take all the provided elements, and assign them with an index based on table.sort
	local len = 0
	for _ in format do
		len += 1
	end

	local structure = table.create(len) :: { any }

	for k in format do
		table.insert(structure, k :: any)
	end

	table.sort(structure)

	local datatype = {
		Eval = "Dict",
		format = format,
	}

	-- Deduplicate format
	format = datatype.format

	datatype.Read = function(reader: types.ReaderData)
		local result = {}

		for i = 1, len do
			local key = structure[i]
			result[key] = format[key].Read(reader)
		end

		return result
	end

	datatype.Write = function(writer: types.WriterData, value: { [any]: types.DatatypeInterface<any> })
		for i = 1, len do
			local key = structure[i]
			format[key].Write(writer, value[key])
		end
	end

	return table.freeze(datatype) :: types.DatatypeInterface<{}>
end
