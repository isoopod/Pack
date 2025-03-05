--!native
--!optimize 2

-- 2025/02/5: Enum:FromValue and Enum:FromName are not recognised by Luau LSP, so this file will not use strict mode for now.

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

return function(enum: Enum): types.DatatypeInterface<EnumItem>
	-- Try and use a u8 for the value of this enum, but if the enum has items with values outside the range of a u8
	-- Use a u16 instead (works for all enums with a use case). Material and Keycode will use a u16 for example.
	local len = 1
	local op = "u8"

	for _, v in enum:GetEnumItems() do
		if v.value > 255 then
			len = 2
			op = "u16"
			break
		end
	end

	return table.freeze({
		Eval = `Enum`,
		Item = enum, -- In a union, we might have multiple enums
		Read = function(reader: types.ReaderData): EnumItem
			return enum:FromValue(Reader[op](reader)) :: EnumItem
		end,
		Write = function(writer: types.WriterData, value: EnumItem)
			Writer.alloc(writer, len)
			Writer[op](writer, value.Value)
		end,
	})
end
