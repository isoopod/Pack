--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u16 = Writer.u16

return function<K, V>(keyType: types.DatatypeInterface<K>, valueType: types.DatatypeInterface<V>): types.DatatypeInterface<{ [K]: V }>
	local kread, kwrite = keyType.Read, keyType.Write
	local vread, vwrite = valueType.Read, valueType.Write

	local datatype = {
		Eval = "Map",
		Key = keyType,
		Val = valueType,
	}

	-- Deduplicate
	keyType = datatype.Key
	valueType = datatype.Val

	datatype.Read = function(reader: types.ReaderData): { [K]: V }
		local len = read_u16(reader)

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

		write_alloc(writer, 2)
		write_u16(writer, len)

		for k, v in value do
			kwrite(writer, k)
			vwrite(writer, v)
		end
	end

	return table.freeze(datatype) :: types.DatatypeInterface<{ [K]: V }>
end
