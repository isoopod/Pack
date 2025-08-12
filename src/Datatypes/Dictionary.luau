--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local typePriority = {
	["number"] = 1,
	["string"] = 2,
	["boolean"] = 3,
	["table"] = 4,
	["function"] = 5,
	["userdata"] = 6,
	["thread"] = 7,
	["nil"] = 8,
}

local function keyComparator(a: any, b: any): boolean
	local ta, tb = type(a), type(b)
	if ta ~= tb then return (typePriority[ta] :: number) < (typePriority[tb] :: number) end

	if ta == "number" or ta == "string" then return a < b end

	return tostring(a) < tostring(b)
end

return function(format: { [any]: types.DatatypeInterface<any> }): types.DatatypeInterface<{}>
	-- In order to make it so we can read and write a dictionary in the same order, we will
	-- take all the provided elements, and assign them with an index based on table.sort
	local len = 0
	for _ in format do
		len += 1
	end

	local approximateLen = 0
	local structure = table.create(len) :: { any }

	for k, v in format do
		approximateLen += v.Len or 0
		table.insert(structure, k :: any)
	end

	table.sort(structure, keyComparator)

	local datatype = {
		Eval = "Dict",
		Len = approximateLen,
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
