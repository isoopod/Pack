--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

-- Marks a value as being nullable / optional, and prefixing it with a bool to indicate if it was written or not.
-- Should not be used inside a union.
-- If you wish to make a union nullable, use Pack.null inside the union

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<T?>
	local read, write = valueType.Read, valueType.Write

	return table.freeze({
		Read = function(Reader: types.Reader): T?
			if Reader:u8() == 1 then return read(Reader) end
			return nil
		end,
		Write = function(Writer: types.Writer, value: any)
			local bool = value ~= nil and 1 or 0
			Writer:u8(bool)

			if bool then write(Writer, value) end
		end,
	}) :: types.DatatypeInterface<T?>
end
