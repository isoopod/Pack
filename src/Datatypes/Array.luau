--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u16 = Reader.u16
local write_alloc = Writer.alloc
local write_u16 = Writer.u16

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<{ T }>
	local read, write = valueType.Read, valueType.Write

	return table.freeze({
		Eval = "Array",
		Of = valueType.Eval,
		Read = function(reader: types.ReaderData): { T }
			local len = read_u16(reader)
			local array = table.create(len) :: { T }

			for i = 1, len do
				array[i] = read(reader)
			end

			return array
		end,
		Write = function(writer: types.WriterData, value: { T })
			local len = #value
			write_alloc(writer, 2)
			write_u16(writer, len)

			for i = 1, len do
				write(writer, value[i])
			end
		end,
	}) :: types.DatatypeInterface<{ T }>
end
