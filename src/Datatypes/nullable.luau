--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

-- Marks a value as being nullable / optional, and prefixing it with a bool to indicate if it was written or not

return function<T>(valueType: types.DatatypeInterface<T>): types.DatatypeInterface<T?>
	local read, write = valueType.Read, valueType.Write

	return {
		Read = function(Reader: types.Reader): T?
			if Reader:u8() == 1 then return read(Reader) end
			return nil
		end,
		Write = function(Writer: types.Writer, value: any)
			local bool = value ~= nil and 1 or 0
			Writer:u8(bool)

			if bool then write(Writer, value) end
		end,
	}
end
