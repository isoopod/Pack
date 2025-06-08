--!strict
--!native
--!optimize 2

local BitReader = require("../BitReader")
local BitWriter = require("../BitWriter")
local types = require("../types")

local bitr_read = BitReader.read

local bitw_alloc = BitWriter.alloc
local bitw_write = BitWriter.write

-- Marks a value as being nullable / optional, and prefixing it with a bool to indicate if it was written or not.
-- Should not be used inside a union.
-- If you wish to make a union nullable, use Pack.null inside the union

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<T?>
	local read, write = valueType.Read, valueType.Write

	return table.freeze({
		Eval = "nullable",
		dt = valueType,
		Read = function(reader: types.ReaderData): T?
			if bitr_read(reader, 1) == 1 then return read(reader) end
			return nil
		end,
		Write = function(writer: types.WriterData, value: any)
			bitw_alloc(writer, 1)

			local bool = value ~= nil and 1 or 0
			bitw_write(writer, 1, bool)

			if bool == 1 then write(writer, value) end
		end,
	}) :: types.DatatypeInterface<T?>
end
