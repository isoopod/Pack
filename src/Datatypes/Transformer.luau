--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

-- Wrapper to transform raw data to and from a more efficient format for storage, or apply data normalization

local function defaultTransform(value)
	return value
end

return function<T, U>(format: types.DatatypeInterface<U>, encode: (T) -> U, decode: (U) -> T)
	encode = encode or defaultTransform
	decode = decode or defaultTransform

	return table.freeze({
		Read = function(reader: types.ReaderData): T
			return decode(format.Read(reader))
		end,
		Write = function(writer: types.WriterData, value: T)
			format.Write(writer, encode(value))
		end,
		Eval = "Transformer",
		Form = format.Eval,
		enc = encode,
	})
end
