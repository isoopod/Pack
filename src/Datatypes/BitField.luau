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

local table_create = table.create

return function(length: number): types.DatatypeInterface<{ boolean }>
	-- Returns a datatype that reads and writes a sequence of booleans as bits.
	return table.freeze({
		Eval = "BitField",
		BitLen = length,
		Read = function(reader: types.ReaderData): { boolean }
			local len = length -- Capture upvalue once
			local result = table_create(len, false) :: { boolean }
			local idx = 1
			local remaining = len

			local read = bitr_read
			while remaining > 0 do
				local chunkSize = math.min(32, remaining)
				local chunk = read(reader, chunkSize)

				for i = 0, chunkSize - 1 do
					result[idx] = bit32.extract(chunk, i) == 1
					idx += 1
				end

				remaining -= chunkSize
			end

			return result
		end,

		Write = function(writer: types.WriterData, value: { boolean })
			-- Reserve space for all bits
			local len = length -- Capture upvalue once
			bitw_alloc(writer, len)
			local idx = 1
			local remaining = len

			local write = bitw_write
			while remaining > 0 do
				local chunkSize = math.min(32, remaining)
				local chunk = 0

				for i = 0, chunkSize - 1 do
					if value[idx] then
						chunk += bit32.lshift(1, i)
					end
					idx += 1
				end

				write(writer, chunkSize, chunk)
				remaining -= chunkSize
			end
		end,
	}) :: types.DatatypeInterface<{ boolean }>
end
