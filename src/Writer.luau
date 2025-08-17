--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local BitWriter = require(script.Parent.BitWriter)
local types = require(script.Parent.types)

local GROWTH_FACTOR = 2

--[=[
	@class Writer
	An internal buffer builder used to serialize packets. Operations are added to a queue and the entire buffer will be created in one pass without needing to dynamically resize the buffer.  
	A writer instance is created with the .new constructor, and is modified with the library's functions.
]=]

local Writer = {}

--[=[
	@function alloc
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param bytes number -- The number of bytes to allocate
	Most Writer functions will not automatically allocate length to the buffer, instead opting to make this call as few times as possible when writing a datatype.  
	Functions that do allocate will be marked with the Allocating tag. Otherwise, figure out how many bytes you need to allocate and call Writer.alloc
]=]
function Writer.alloc(self: types.WriterData, bytes: number)
	local currentSize = self._len
	local requiredSize = currentSize + bytes

	self._len = requiredSize

	-- In the case the buffer is not large enough, resize it.
	if self._len > self._allocatedLen then
		local newSize = math.max(self._allocatedLen, 1) -- Avoid growing from 0

		repeat
			newSize = math.ceil(newSize * GROWTH_FACTOR)
		until newSize >= requiredSize

		local newBuffer = buffer.create(newSize)
		buffer.copy(newBuffer, 0, self._buffer, 0, currentSize)

		self._buffer = newBuffer
		self._allocatedLen = newSize
	end
end

----
--[=[
	@function u8
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**1 byte**  
	Writes an 8-bit unsigned integer into the packet 
]=]
function Writer.u8(self: types.WriterData, value: number)
	buffer.writeu8(self._buffer, self._cursor, value)
	self._cursor += 1
end

--[=[
	@function u16
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**2 bytes**  
	Writes a 16-bit unsigned integer into the packet 
]=]
function Writer.u16(self: types.WriterData, value: number)
	buffer.writeu16(self._buffer, self._cursor, value)
	self._cursor += 2
end

--[=[
	@function u32
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**4 bytes**  
	Writes a 32-bit unsigned integer into the packet 
]=]
function Writer.u32(self: types.WriterData, value: number)
	buffer.writeu32(self._buffer, self._cursor, value)
	self._cursor += 4
end

--[=[
	@function i8
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**1 bytes**  
	Writes an 8-bit signed integer into the packet 
]=]
function Writer.i8(self: types.WriterData, value: number)
	buffer.writei8(self._buffer, self._cursor, value)
	self._cursor += 1
end

--[=[
	@function i16
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**2 bytes**  
	Writes a 16-bit signed integer into the packet 
]=]
function Writer.i16(self: types.WriterData, value: number)
	buffer.writei16(self._buffer, self._cursor, value)
	self._cursor += 2
end

--[=[
	@function i32
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**4 bytes**  
	Writes a 32-bit signed integer into the packet 
]=]
function Writer.i32(self: types.WriterData, value: number)
	buffer.writei32(self._buffer, self._cursor, value)
	self._cursor += 4
end

--[=[
	@function nBitUint
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	@param n number -- The length of the integer in bits
	@param bitOffset number -- The offset from the cursor in bits to start writing at [0 – 31]
	**`math.floor(n / 8) + 1` bytes**  
	Writes an unsigned `n`-bit integer into the packet 
	:::info
	nBitUint does not automatically move the writers cursor so you will have to call 
	Writer.moveCursor the appropriate number of bytes after writing a section of nBit numbers.
	:::
]=]
function Writer.nBitUint(self: types.WriterData, value: number, n: number, bitOffset: number)
	buffer.writebits(self._buffer, self._cursor * 8 + bitOffset, n, value)
end

--[=[
	@function nBitInt
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	@param n number -- The length of the integer in bits
	@param bitOffset number -- The offset from the cursor in bits to start writing at [0 – 31]
	**`math.floor(n / 8) + 1` bytes**  
	Writes a signed `n`-bit integer into the packet 
	:::info
	nBitInt does not automatically move the writers cursor so you will have to call 
	Writer.moveCursor the appropriate number of bytes after writing a section of nBit numbers.
	:::
]=]
function Writer.nBitInt(self: types.WriterData, value: number, n: number, bitOffset: number)
	buffer.writebits(self._buffer, self._cursor * 8 + bitOffset, n, value < 0 and value + 2 ^ n or value)
end

--[=[
	@function nBitFloat
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	@param n number -- The length in bits of the floating point's exponent
	@param m number -- The length in bits of the floating point's mantissa
	@param bitOffset number -- The offset from the cursor in bits to start writing at [0 – 31]
	**`math.floor((1 + n + m) / 8) + 1` bytes**  
	Writes a floating point number into the packet 
	:::info
	nBitFloat does not automatically move the writer's cursor so you will have to call 
	Writer.moveCursor the appropriate number of bytes after writing a section of nBit numbers.
	:::
	:::warning
	The sum of `n` and `m` should not be greater than `31 - bitOffset`.  
	:::
]=]
function Writer.nBitFloat(self: types.WriterData, value: number, n: number, m: number, bitOffset: number)
	-- n: number of exponent bits, m: number of mantissa bits.
	-- IEEE754: bias = 2^(n-1)-1
	local sign = 0
	local storedExponent = 0
	local mantissa = 0

	if value ~= value then
		-- NaN: IEEE 754 requires exponent to be all ones and mantissa non-zero.
		sign = 0
		storedExponent = (bit32.lshift(1, n)) - 1
		mantissa = 1 -- any non-zero value within m bits
	elseif value == math.huge or value == -math.huge then
		sign = value < 0 and 1 or 0
		storedExponent = (bit32.lshift(1, n)) - 1
		mantissa = 0
	else
		sign = value < 0 and 1 or 0
		local fAbs = math.abs(value)
		local bias = (bit32.lshift(1, n - 1)) - 1
		if fAbs == 0 then
			-- Zero is represented with all exponent and mantissa bits zero.
			storedExponent = 0
			mantissa = 0
		else
			-- Get normalized fraction and exponent via frexp.
			local fNormalized, exponent = math.frexp(fAbs)
			-- Adjust to have fNormalized in [1,2) and e = exponent - 1.
			local e = exponent - 1

			if e + bias >= 1 then
				-- Normalised number.
				storedExponent = e + bias
				-- The implicit bit is removed; fraction = fNormalized * 2 - 1.
				local fraction = (fNormalized * 2) - 1
				-- Round the mantissa to nearest.
				mantissa = math.floor(fraction * (2 ^ m) + 0.5)
				-- Handle rounding overflow.
				if mantissa >= (2 ^ m) then
					mantissa = 0
					storedExponent = storedExponent + 1
					if storedExponent >= (bit32.lshift(1, n)) - 1 then
						-- Overflow to infinity.
						storedExponent = (bit32.lshift(1, n)) - 1
						mantissa = 0
					end
				end
			else
				-- Subnormal number.
				storedExponent = 0
				-- For subnormals, the value is represented as:
				--   value = (mantissa / 2^m) * 2^(1 - bias)
				-- Rearranging gives:
				--   mantissa = fAbs * 2^(m + bias - 1)
				mantissa = math.floor(fAbs * (2 ^ (m + bias - 1)) + 0.5)
				-- Clamp to m bits.
				if mantissa >= (2 ^ m) then mantissa = (2 ^ m) - 1 end
			end
		end
	end

	-- Combine sign, exponent, and mantissa
	local combined = bit32.bor(bit32.lshift(sign, n + m), bit32.lshift(storedExponent, m), mantissa)

	buffer.writebits(self._buffer, self._cursor * 8 + bitOffset, 1 + n + m, combined)
end

--[=[
	@function f32
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**4 bytes**  
	Writes a 32-bit floating point number into the packet 
]=]
function Writer.f32(self: types.WriterData, value: number)
	buffer.writef32(self._buffer, self._cursor, value)
	self._cursor += 4
end

--[=[
	@function f64
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**8 bytes**  
	Writes a 64-bit floating point number into the packet 
]=]
function Writer.f64(self: types.WriterData, value: number)
	buffer.writef64(self._buffer, self._cursor, value)
	self._cursor += 8
end

--[=[
	@function string
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value string -- The string you wish to write
	@param count number? -- Optional value denoting the maximum number of bytes to write
	@return number -- the length of the string in bytes
	@return () -> () -- A function that orders the wring into the packet
	@tag Allocating
	Processes a string into a seperate buffer and allocates the byte length of the string (or if count is provided and smaller than blen, allocates `count` bytes)  
	Returns the amount of bytes allocated, and a function to commit the string to the packet.  
	This is so the length of the string can be written before writing the string itself, for variable length strings.
]=]
function Writer.string(self: types.WriterData, value: string, count: number?): (number, () -> ())
	local s = buffer.fromstring(value)
	local blen = math.min(buffer.len(s), count or math.huge)

	return blen, function()
		Writer.alloc(self, blen)
		buffer.copy(self._buffer, self._cursor, s, 0, count)
		self._cursor += blen
	end
end

--[=[
	@function stringFixed
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value string -- The string you wish to write
	@param count number? -- Optional value denoting the maximum number of bytes to write
	When we already know the length of the string, we can write it directly to the buffer without needing to
]=]
function Writer.stringFixed(self: types.WriterData, value: string, count: number)
	buffer.writestring(self._buffer, self._cursor, value, count)
	self._cursor += count
end

--[=[
	@function moveCursor
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param delta number -- How many bytes to move the cursor, can be negative to go backwards
	Manually moves the writer's cursor.  
	:::danger
	Does not prevent you from leaving buffer bounds.
	:::
]=]
function Writer.moveCursor(self: types.WriterData, delta: number)
	self._cursor += delta
end

function Writer.addRef(self: types.WriterData, ref: any)
	self.nRefs += 1
	self.refs[self.nRefs] = ref
end
----

local function trimBuffer(self: types.WriterData)
	local len = self._len
	-- If the buffer is smaller than the allocated size, we can trim it to the correct size
	if len < self._allocatedLen then
		local trimmed = buffer.create(len)
		buffer.copy(trimmed, 0, self._buffer, 0, len)
		self._buffer = trimmed
	end
end

--[=[
	@function Finalize
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@return buffer
	Finalizes the packet by writing the bit buffer and trimming the main buffer to the correct size.
]=]
function Writer.Finalize(self: types.WriterData): buffer
	-- Allocate room for the bit buffer, write the bit buffer, and then trim the buffer to the correct size
	if self._bitLen ~= 0 then
		Writer.alloc(self, math.ceil(self._bitLen / 8))
		trimBuffer(self)
		BitWriter.Finalize(self)
	else
		trimBuffer(self)
	end

	return self._buffer
end

--[=[
	@function new
	@within Writer
	@param approxLen number? -- Optional approximate length of the buffer to be created. This is used to preallocate the buffer size so less resizes are needed.
	@param approxBitLen number? -- Optional approximate length of the bit buffer to be created. This is used to preallocate the bit buffer size so less resizes are needed.
	@return WriterData
	@tag Constructor
	Creates an empty writer instance
]=]
function Writer.new(approximateLen: number?, approximateBitLen: number?): types.WriterData
	local self = {}

	self.nRefs = 0

	self._len = 0
	self._allocatedLen = approximateLen or 0
	self._cursor = 0
	self._buffer = buffer.create(approximateLen or 0)

	-- We can assume that if there 0 bits are expected, we don't need to use a bit buffer.
	if approximateBitLen and approximateBitLen > 0 then
		local bytes = math.ceil(approximateBitLen / 8)

		self._bitLen = 0
		self._allocatedBitLen = bytes * 8
		self._bitCursor = approximateBitLen
		self._bitBuffer = buffer.create(bytes)
	end

	return self :: any
end

return table.freeze(Writer) :: types.Writer
