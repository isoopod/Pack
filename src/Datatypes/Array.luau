--!native
--!optimize 2

const types = require(script.Parent.Parent.types)

const UInt16 = require(script.Parent.UInt16)

const DEBUG = types.DEBUG

return function<T>(valueType: types.DatatypeInterface<T>, lengthType: types.DatatypeInterface<number>?): types.DatatypeInterface<{ T }>
	lengthType = lengthType or UInt16
	const read, write = valueType.Read, valueType.Write
	const lenRead, lenWrite = lengthType.Read, lengthType.Write

	if DEBUG then DEBUG.Array.CheckLenType(lengthType) end

	return table.freeze({
		Eval = "Array",
		Len = lengthType.Len,
		Of = valueType,
		Read = function(reader: types.ReaderData): { T }
			const len = lenRead(reader)
			const array = table.create(len) :: { T }

			for i = 1, len do
				array[i] = read(reader)
			end

			return array
		end,
		Write = function(writer: types.WriterData, value: { T })
			const len = #value
			lenWrite(writer, len)

			for i = 1, len do
				write(writer, value[i])
			end
		end,
	}) :: types.DatatypeInterface<{ T }>
end
