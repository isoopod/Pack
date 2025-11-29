--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local UInt16 = require(script.Parent.UInt16)

local DEBUG = types.DEBUG

return function<T>(valueType: types.DatatypeInterface<T>, lengthType: types.DatatypeInterface<number>?): types.DatatypeInterface<{ T }>
	lengthType = lengthType or UInt16
	local read, write = valueType.Read, valueType.Write
	local lenRead, lenWrite = lengthType.Read, lengthType.Write

	if DEBUG then DEBUG.Array.CheckLenType(lengthType) end

	return table.freeze({
		Eval = "Array",
		Len = lengthType.Len,
		Of = valueType,
		Read = function(reader: types.ReaderData): { T }
			local len = lenRead(reader)
			local array = table.create(len) :: { T }

			for i = 1, len do
				array[i] = read(reader)
			end

			return array
		end,
		Write = function(writer: types.WriterData, value: { T })
			local len = #value
			lenWrite(writer, len)

			for i = 1, len do
				write(writer, value[i])
			end
		end,
	}) :: types.DatatypeInterface<{ T }>
end
