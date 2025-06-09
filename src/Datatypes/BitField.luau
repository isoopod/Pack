--!strict
--!native
--!optimize 2

-- Leverages the packet bit buffer to implement a fixed-length bitfield efficiently.
-- TODO: Profile writebits and readbits to see if chunking should be reimplemented.

local BitReader = require(script.Parent.Parent.BitReader)
local BitWriter = require(script.Parent.Parent.BitWriter)
local types = require(script.Parent.Parent.types)

local bitr_read = BitReader.read

local bitw_alloc = BitWriter.alloc
local bitw_write = BitWriter.write

return function(length: number): types.DatatypeInterface<{ boolean }>
	-- Returns a datatype that reads and writes a sequence of booleans as bits.
	return table.freeze({
		Eval = "BitField",
		Read = function(reader: types.ReaderData): { boolean }
			local result = table.create(length, false)

			-- Read each bit sequentially
			for i = 1, length do
				local bitValue = bitr_read(reader, 1)
				if bitValue == 1 then result[i] = true end
			end

			return result
		end,

		Write = function(writer: types.WriterData, value: { boolean })
			-- Reserve space for all bits
			bitw_alloc(writer, length)

			-- Write each boolean as a single bit
			for i = 1, length do
				local bitValue = value[i] and 1 or 0
				bitw_write(writer, 1, bitValue)
			end
		end,
	}) :: types.DatatypeInterface<{ boolean }>
end
