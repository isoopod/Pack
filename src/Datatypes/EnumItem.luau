--!native
--!optimize 2

-- 2025/02/5: Enum:FromValue and Enum:FromName are not recognised by Luau LSP, so this file will not use strict mode for now.

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u8 = Reader.u8
local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u8 = Writer.u8
local write_u16 = Writer.u16

return function(enum: Enum): types.DatatypeInterface<EnumItem>
	-- Try and use a u8 for the value of this enum, but if the enum has items with values outside the range of a u8
	-- Use a u16 instead (works for all enums with a use case). Material and Keycode will use a u16 for example.
	local len = 1
	local read_op = read_u8
	local write_op = write_u8

	for _, v in enum:GetEnumItems() do
		if v.Value > 255 then
			len = 2
			read_op = read_u16
			write_op = write_u16
			break
		end
	end

	return table.freeze({
		Eval = `Enum`,
		Item = enum, -- In a union, we might have multiple enums
		Read = function(reader: types.ReaderData): EnumItem
			return enum:FromValue(read_op(reader)) :: EnumItem
		end,
		Write = function(writer: types.WriterData, value: EnumItem)
			write_alloc(writer, len)
			write_op(writer, value.Value)
		end,
	}) :: types.DatatypeInterface<EnumItem>
end
