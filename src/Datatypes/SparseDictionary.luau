--!strict
--!native
--!optimize 2

local BitField = require(script.Parent.BitField)
local types = require(script.Parent.Parent.types)

local DEBUG = types.DEBUG

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

return function(optionalFormat: { [any]: types.DatatypeInterface<any> }, requiredFormat: { [any]: types.DatatypeInterface<any> }?): types.DatatypeInterface<{}>
	-- In order to make it so we can read and write a dictionary in the same order, we will
	-- take all the provided elements, and assign them with an index based on table.sort
	local optLen, reqLen = 0, 0
	local optStructure: { any }, reqStructure: { any }

	for _ in optionalFormat do
		optLen += 1
	end

	optStructure = table.create(optLen) :: { any }

	for k in optionalFormat do
		table.insert(optStructure, k :: any)
	end

	table.sort(optStructure, keyComparator)

	if requiredFormat then
		for _ in requiredFormat do
			reqLen += 1
		end

		reqStructure = table.create(reqLen) :: { any }

		for k in requiredFormat do
			table.insert(reqStructure, k :: any)
		end

		table.sort(reqStructure, keyComparator)
	end

	local occupancyField = BitField(optLen)

	local datatype = {
		Eval = "Dict",
		format = requiredFormat,
		optFormat = optionalFormat,
	}

	-- Deduplicate formats
	requiredFormat = datatype.format
	optionalFormat = datatype.optFormat

	function datatype.Read(reader: types.ReaderData)
		local result = {}

		local occupied = occupancyField.Read(reader)
		for i = 1, optLen do
			if occupied[i] then
				local key = optStructure[i]
				result[key] = optionalFormat[key].Read(reader)
			end
		end

		if requiredFormat then
			for i = 1, reqLen do
				local key = reqStructure[i]
				result[key] = requiredFormat[key].Read(reader)
			end
		end

		return result
	end

	function datatype.Write(writer: types.WriterData, value: { [any]: types.DatatypeInterface<any> })
		local occupied: { boolean }, occupiedWrite: { any } = {}, {}
		for i = 1, optLen do
			local key = optStructure[i]
			local occ = value[key] ~= nil
			table.insert(occupied, occ)
			if occ then table.insert(occupiedWrite, key) end
		end

		occupancyField.Write(writer, occupied)

		for i = 1, #occupiedWrite do
			local key = occupiedWrite[i]
			optionalFormat[key].Write(writer, value[key])
		end

		if DEBUG then DEBUG.SparseDictionary.CheckRequired(reqStructure, value) end

		if requiredFormat then
			for i = 1, reqLen do
				local key = reqStructure[i]
				requiredFormat[key].Write(writer, value[key])
			end
		end
	end

	return table.freeze(datatype) :: types.DatatypeInterface<{}>
end
