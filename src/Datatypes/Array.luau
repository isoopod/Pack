--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<{ T }>
	local read, write = valueType.Read, valueType.Write

	return table.freeze({
		Eval = "Array",
		Of = valueType.Eval,
		Read = function(reader: types.ReaderData): { T }
			local len = Reader.u16(reader)
			local array = table.create(len) :: { T }

			for i = 1, len do
				array[i] = read(reader)
			end

			return array
		end,
		Write = function(writer: types.WriterData, value: { T })
			local len = #value
			Writer.alloc(writer, 2)
			Writer.u16(writer, len)

			for i = 1, len do
				write(writer, value[i])
			end
		end,
	}) :: types.DatatypeInterface<{ T }>
end
