--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u8 = Reader.u8

local write_alloc = Writer.alloc
local write_u8 = Writer.u8

-- Marks a value as being nullable / optional, and prefixing it with a bool to indicate if it was written or not.
-- Should not be used inside a union.
-- If you wish to make a union nullable, use Pack.null inside the union

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<T?>
	local read, write = valueType.Read, valueType.Write

	return table.freeze({
		Eval = "nullable",
		dt = valueType,
		Read = function(reader: types.ReaderData): T?
			if read_u8(reader) == 1 then return read(reader) end
			return nil
		end,
		Write = function(writer: types.WriterData, value: any)
			write_alloc(writer, 1)

			local bool = value ~= nil and 1 or 0
			write_u8(writer, bool)

			if bool == 1 then write(writer, value) end
		end,
	}) :: types.DatatypeInterface<T?>
end
