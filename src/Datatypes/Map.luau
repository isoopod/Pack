--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

return function<K, V>(keyType: types.DatatypeInterface<K>, valueType: types.DatatypeInterface<V>): types.DatatypeInterface<{ [K]: V }>
	local kread, kwrite = keyType.Read, keyType.Write
	local vread, vwrite = valueType.Read, valueType.Write

	return {
		Read = function(Reader: types.Reader): { [K]: V }
			local len = Reader:u16()

			local map = {}

			for _ = 1, len do
				map[kread(Reader)] = vread(Reader)
			end

			return map
		end,
		Write = function(Writer: types.Writer, value: { [K]: V })
			local len = 0
			for _ in value do
				len += 1
			end

			Writer:alloc(2)
			Writer:u16(len)

			for k, v in value do
				kwrite(Writer, k)
				vwrite(Writer, v)
			end
		end,
	}
end
