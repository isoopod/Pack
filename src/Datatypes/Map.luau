--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local UInt16 = require(script.Parent.UInt16)

local DEBUG = types.DEBUG

return function<K, V>(keyType: types.DatatypeInterface<K>, valueType: types.DatatypeInterface<V>, lengthType: types.DatatypeInterface<number>?): types.DatatypeInterface<{ [K]: V }>
	lengthType = lengthType or UInt16
	local lenRead, lenWrite = lengthType.Read, lengthType.Write

	local kread, kwrite = keyType.Read, keyType.Write
	local vread, vwrite = valueType.Read, valueType.Write

	if DEBUG then DEBUG.Array.CheckLenType(lengthType) end

	local datatype = {
		Eval = "Map",
		Len = lengthType.Len,
		Key = keyType,
		Val = valueType,
	}

	-- Deduplicate
	keyType = datatype.Key
	valueType = datatype.Val

	datatype.Read = function(reader: types.ReaderData): { [K]: V }
		local len = lenRead(reader)

		local map = {}

		for _ = 1, len do
			map[kread(reader)] = vread(reader)
		end

		return map
	end

	datatype.Write = function(writer: types.WriterData, value: { [K]: V })
		local len = 0
		for _ in value do
			len += 1
		end

		lenWrite(writer, len)

		for k, v in value do
			kwrite(writer, k)
			vwrite(writer, v)
		end
	end

	return table.freeze(datatype) :: types.DatatypeInterface<{ [K]: V }>
end
