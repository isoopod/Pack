--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

return function<K, V>(keyType: types.DatatypeInterface<K>, valueType: types.DatatypeInterface<V>): types.DatatypeInterface<{ [K]: V }>
	local kread, kwrite = keyType.Read, keyType.Write
	local vread, vwrite = valueType.Read, valueType.Write

	return table.freeze({
		Eval = "Map",
		Read = function(reader: types.ReaderData): { [K]: V }
			local len = Reader.u16(reader)

			local map = {}

			for _ = 1, len do
				map[kread(reader)] = vread(reader)
			end

			return map
		end,
		Write = function(writer: types.WriterData, value: { [K]: V })
			local len = 0
			for _ in value do
				len += 1
			end

			Writer.alloc(writer, 2)
			Writer.u16(writer, len)

			for k, v in value do
				kwrite(writer, k)
				vwrite(writer, v)
			end
		end,
	}) :: types.DatatypeInterface<{ [K]: V }>
end
