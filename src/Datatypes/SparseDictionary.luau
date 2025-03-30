--!strict
--!native
--!optimize 2

local BitField = require(script.Parent.BitField)
local types = require(script.Parent.Parent.types)

return function(optionalFormat: { [any]: types.DatatypeInterface<any> }, requiredFormat: { [any]: types.DatatypeInterface<any> }): types.DatatypeInterface<{}>
	-- In order to make it so we can read and write a dictionary in the same order, we will
	-- take all the provided elements, and assign them with an index based on table.sort
	local optLen, reqLen = 0, 0
	local optStructure: { any }, reqStructure: { any }

	for _ in optionalFormat do
		optLen += 1
	end

	optStructure = table.create(optLen) :: { any }

	for k in optionalFormat do
		table.insert(optStructure, k)
	end

	table.sort(optStructure)

	for _ in requiredFormat do
		reqLen += 1
	end

	reqStructure = table.create(reqLen) :: { any }

	for k in requiredFormat do
		table.insert(reqStructure, k)
	end

	table.sort(reqStructure)

	local occupancyField = BitField(optLen)

	return table.freeze({
		Eval = "SDict",

		Read = function(reader: types.ReaderData)
			local result = {}

			local occupied = occupancyField.Read(reader)
			for i = 1, optLen do
				if occupied[i] then
					local key = optStructure[i]
					result[key] = optionalFormat[key].Read(reader)
				end
			end

			for i = 1, reqLen do
				local key = reqStructure[i]
				result[key] = requiredFormat[key].Read(reader)
			end

			return result
		end,
		Write = function(writer: types.WriterData, value: { [any]: types.DatatypeInterface<any> })
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

			for i = 1, reqLen do
				local key = reqStructure[i]
				requiredFormat[key].Write(writer, value[key])
			end
		end,
	}) :: types.DatatypeInterface<{}>
end
