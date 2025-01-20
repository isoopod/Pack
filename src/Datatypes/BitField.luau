--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local BIT_MASKS = {}
for i = 0, 31 do
	BIT_MASKS[i + 1] = 2 ^ i
end

local bor = bit32.bor
local band = bit32.band

--[=[
        @function BitField
        @within Datatypes
		@param Length: number
        A Pack 'BitField' is a compact representation of many boolean values, being able to fit 8 into a single byte.  
		A predetermined length (the number of booleans, not bytes) must be provided, and it is accessed through arrays of booleans of that length.
		When writing, if your array is shorter than the length of the BitField, the booleans that were not provided will be treated as false.

		:::hint
		Dont use a BitField to store a single bool, Use the standard Pack 'boolean' instead.
		:::
]=]

return function(length: number): types.DatatypeInterface<{ boolean }>
	local byteLength = (length + 7) // 8

	-- The reason we write a variable amount is to be more efficient with bit32
	-- Since it uses 32 bits, we write 4 bytes at once if possible.
	return {
		Read = function(Reader: types.Reader): { boolean }
			local result = table.create(length, false)

			for i = 1, length, 32 do
				-- Get the remaining length to determine how many bits to read
				local remainingBits = math.min(32, length - i + 1)

				-- Read the appropriate chunk size
				local chunk
				if remainingBits > 16 then
					chunk = Reader:u32()
				elseif remainingBits > 8 then
					chunk = Reader:u16()
				else
					chunk = Reader:u8()
				end

				-- Extract bits from the chunk
				for j = 1, remainingBits do
					if band(chunk, BIT_MASKS[j]) ~= 0 then
						result[i + j - 1] = true -- Only overwrite if the bit is on
					end
				end
			end

			return result
		end,
		Write = function(Writer: types.Writer, value: { boolean })
			Writer:alloc(byteLength)

			for i = 1, length, 32 do
				local bitbuffer = table.create(32) :: { number } -- Preallocate the max chunk size
				for j = 1, 32 do
					if i + j > length then break end -- We have reached the end of the bit field so break early
					local bit = value[i + j]

					bitbuffer[j] = bit and BIT_MASKS[j] or 0
				end

				-- Write the appropriate chunk size
				local chunk = bor(unpack(bitbuffer))
				local filledBits = #bitbuffer
				if filledBits > 16 then
					Writer:u32(chunk)
				elseif filledBits > 8 then
					Writer:u16(chunk)
				else
					Writer:u8(chunk)
				end
			end
		end,
	}
end
