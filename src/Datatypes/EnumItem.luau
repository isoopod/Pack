--!native
--!optimize 2

-- 2025/02/5: Enum:FromValue and Enum:FromName are not recognised by Luau LSP, so this file will not use strict mode for now.

local BitReader = require(script.Parent.Parent.BitReader)
local BitWriter = require(script.Parent.Parent.BitWriter)
local types = require(script.Parent.Parent.types)

local bitr_read = BitReader.read

local bitw_alloc = BitWriter.alloc
local bitw_write = BitWriter.write

return function(enum: Enum): types.DatatypeInterface<EnumItem>
	-- Try to use the least bits possible to store the value
	local max = 0
	for _, v: EnumItem in enum:GetEnumItems() do
		local val = v.Value
		if val > max then max = val end
	end
	local blen = math.floor(math.log(max, 2)) + 1

	return table.freeze({
		Eval = `Enum`,
		BitLen = blen,
		Item = enum, -- In a union, we might have multiple enums
		Read = function(reader: types.ReaderData): EnumItem
			return enum:FromValue(bitr_read(reader, blen)) :: EnumItem
		end,
		Write = function(writer: types.WriterData, value: EnumItem)
			bitw_alloc(writer, blen)
			bitw_write(writer, blen, value.Value)
		end,
	}) :: types.DatatypeInterface<EnumItem>
end
