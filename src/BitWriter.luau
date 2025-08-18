--!strict
--!native
--!optimize 2

local types = require(script.Parent.types)

local GROWTH_FACTOR = 2

--[=[
	@class BitWriter
	Internal bit buffer builder library. Writes right to left, as the bitbuffer is appended to the end of the packet.
	A `BitWriter` accumulates a series of bit-level write and move operations, which are then packed into a binary buffer during finalisation.
]=]

local Writer = {}

--[=[
	@function alloc
	@within BitWriter
	@param self WriterData -- A writer instance created with .new
	@param bits number -- Number of bits to allocate.
	Allocates space in the internal bit buffer without writing any values.
	This is used to reserve bits ahead of time.
]=]
function Writer.alloc(self: types.WriterData, bits: number)
	local currentSize = self._bitLen
	local requiredSize = currentSize + bits

	self._bitLen = requiredSize

	-- In the case the buffer is not large enough, resize it.
	if self._bitLen > self._allocatedBitLen then
		local newSize = math.max(self._allocatedBitLen, 1) -- Avoid growing from 0

		repeat
			newSize = math.ceil(newSize * GROWTH_FACTOR)
		until newSize >= requiredSize

		-- Convert bits to bytes
		local currentByteSize = math.ceil(currentSize / 8)
		local newByteSize = math.ceil(newSize / 8)

		local newBuffer = buffer.create(newByteSize)

		-- BitBuffer writes right to left, so we need to copy the existing data to the end of the new buffer.
		local offset = newByteSize - currentByteSize
		buffer.copy(newBuffer, offset, self._buffer, 0, currentByteSize)

		self._bitCursor += offset * 8
		self._bitBuffer = newBuffer
		self._allocatedBitLen = newSize
	end
end

--[=[
	@function write
	@within BitWriter
	@param self WriterData -- A writer instance created with .new
	@param bits number -- Number of bits to write.
	@param value number -- Value to write into the buffer.
	Writes the given number of bits with the specified value.
	The value will be written from right to left in the finalised buffer.
]=]
function Writer.write(self: types.WriterData, bits: number, value: number)
	self._bitCursor -= bits
	buffer.writebits(self._bitBuffer, self._bitCursor, bits, value)
end

--[=[
	@function moveCursor
	@within BitWriter
	@param self WriterData -- A writer instance created with .new
	@param delta number -- Number of bits to move the cursor by.
	Moves the write cursor left by the given number of bits without writing any data.
	Useful for padding or skipping reserved sections of the buffer.
]=]
function Writer.moveCursor(self: types.WriterData, delta: number)
	self._bitCursor -= delta
end

--[=[
	@function Finalize
	@within BitWriter
	@param self WriterData -- A writer instance created with .new
	Finalises the bit buffer and writes into the provided binary buffer.
	Executes all queued write and cursor move operations from right to left.
]=]
function Writer.Finalize(self: types.WriterData)
	local b = self._bitBuffer

	-- Trim the buffer if necessary
	local bitLen = self._bitLen
	local byteLen = math.ceil(bitLen / 8) -- Minimum needed storage

	if bitLen < self._allocatedBitLen then
		local newBuffer = buffer.create(byteLen)

		local oldByteLen = math.ceil(self._allocatedBitLen / 8)
		local offset = oldByteLen - byteLen

		-- Copy only the meaningful bytes (shift to front)
		buffer.copy(newBuffer, 0, self._bitBuffer, offset, byteLen)
		b = newBuffer
	end

	buffer.copy(self._buffer, self._len, b, 0)
end

return Writer
