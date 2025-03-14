--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

-- Marks a value as being nullable / optional, and prefixing it with a bool to indicate if it was written or not.
-- Should not be used inside a union.
-- If you wish to make a union nullable, use Pack.null inside the union

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<T?>
	local read, write = valueType.Read, valueType.Write

	return table.freeze({
		Read = function(reader: types.ReaderData): T?
			if Reader.u8(reader) == 1 then return read(reader) end
			return nil
		end,
		Write = function(writer: types.WriterData, value: any)
			Writer.alloc(writer, 1)

			local bool = value ~= nil and 1 or 0
			Writer.u8(writer, bool)

			if bool then write(writer, value) end
		end,
	}) :: types.DatatypeInterface<T?>
end
