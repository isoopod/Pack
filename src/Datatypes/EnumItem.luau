--!native
--!optimize 2

const BitReader = require(script.Parent.Parent.BitReader)
const BitWriter = require(script.Parent.Parent.BitWriter)
const types = require(script.Parent.Parent.types)

const bitr_read = BitReader.read

const bitw_alloc = BitWriter.alloc
const bitw_write = BitWriter.write

return function(enum: Enum): types.DatatypeInterface<EnumItem>
	-- Try to use the least bits possible to store the value
	local max = 0
	for _, v: EnumItem in enum:GetEnumItems() do
		const val = v.Value
		if val > max then max = val end
	end
	const blen = math.floor(math.log(max, 2)) + 1

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
