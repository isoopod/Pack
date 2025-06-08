--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u32 = Reader.u32
local read_nBitUint = Reader.nBitUint
local read_moveCursor = Reader.moveCursor
local read_u16 = Reader.u16
local read_u8 = Reader.u8

local write_alloc = Writer.alloc
local write_u32 = Writer.u32
local write_nBitUint = Writer.nBitUint
local write_moveCursor = Writer.moveCursor
local write_u16 = Writer.u16
local write_u8 = Writer.u8

local BIT_MASKS = {}
for i = 0, 31 do
	BIT_MASKS[i + 1] = 2 ^ i
end

return function(length: number): types.DatatypeInterface<{ boolean }>
	local byteLength = (length + 7) // 8

	-- The reason we write a variable amount is to be more efficient with bit32
	-- Since it uses 32 bits, we write 4 bytes at once if possible.
	return table.freeze({
		Eval = "BitField",
		Read = function(reader: types.ReaderData): { boolean }
			local result = table.create(length, false)

			for i = 1, length, 32 do
				-- Get the remaining length to determine how many bits to read
				local remainingBits = math.min(32, length - i + 1)

				-- Read the appropriate chunk size
				local chunk
				if remainingBits > 24 then
					chunk = read_u32(reader)
				elseif remainingBits > 16 then
					chunk = read_nBitUint(reader, 24, 0)
					read_moveCursor(reader, 3)
				elseif remainingBits > 8 then
					chunk = read_u16(reader)
				else
					chunk = read_u8(reader)
				end

				-- Extract bits from the chunk
				for j = 1, remainingBits do
					if bit32.band(chunk, BIT_MASKS[j]) ~= 0 then
						result[i + j - 1] = true -- Only overwrite if the bit is on
					end
				end
			end

			return result
		end,
		Write = function(writer: types.WriterData, value: { boolean })
			write_alloc(writer, byteLength)

			for i = 1, length, 32 do
				-- How many bits left in this chunk?
				local remainingBits = math.min(32, length - i + 1)

				-- Build exactly remainingBits entries
				local bitbuffer = {}
				for j = 1, remainingBits do
					if value[i + j - 1] then
						bitbuffer[j] = BIT_MASKS[j]
					else
						bitbuffer[j] = 0
					end
				end

				-- Pack into one integer
				local chunk = bit32.bor(unpack(bitbuffer))

				-- Emit exactly the same width that the reader expects
				if remainingBits > 24 then
					write_u32(writer, chunk)
				elseif remainingBits > 16 then
					write_nBitUint(writer, chunk, 24, 0)
					write_moveCursor(writer, 3)
				elseif remainingBits > 8 then
					write_u16(writer, chunk)
				else
					write_u8(writer, chunk)
				end
			end
		end,
	}) :: types.DatatypeInterface<{ boolean }>
end
