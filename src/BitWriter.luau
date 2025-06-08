--!strict
--!native
--!optimize 2

local types = require(script.Parent.types)

--[=[
	@class BitWriter
	Internal bit buffer builder library. Writes right to left, as the bitbuffer is appended to the end of the packet.
	A `BitWriter` accumulates a series of bit-level write and move operations, which are then packed into a binary buffer during finalisation.
]=]

local Writer = {}

local function split(u32: number): (number, number)
	local low = bit32.band(u32, 0xFFFF)
	local high = bit32.rshift(u32, 16)
	return low, high
end

local function reconstruct(low: number, high: number): number
	return bit32.bor(high * 16777216, low)
end

--[=[
	@function alloc
	@within BitWriter
	@param bits number -- Number of bits to allocate.
	Allocates space in the internal bit buffer without writing any values.
	This is used to reserve bits ahead of time.
]=]
function Writer.alloc(self: types.WriterData, bits: number)
	self._bitLen += bits
end

--[=[
	@function write
	@within BitWriter
	@param bits number -- Number of bits to write.
	@param value number -- Value to write into the buffer.
	Queues a write operation to write the given number of bits with the specified value.
	The value will be written from right to left in the finalised buffer.
]=]
function Writer.write(self: types.WriterData, bits: number, value: number)
	if bits > 24 then
		table.insert(self._bitQueue, vector.create(bits, split(value)))
	else
		table.insert(self._bitQueue, vector.create(bits, value))
	end
end

--[=[
	@function moveCursor
	@within BitWriter
	@param delta number -- Number of bits to move the cursor by.
	Moves the write cursor left by the given number of bits without writing any data.
	Useful for padding or skipping reserved sections of the buffer.
]=]
function Writer.moveCursor(self: types.WriterData, delta: number)
	table.insert(self._bitQueue, vector.create(delta, -1))
end

--[=[
	@function Finalize
	@within BitWriter
	@param b buffer -- The packet being constructed by Writer.
	Finalises the bit buffer and writes into the provided binary buffer.
	Executes all queued write and cursor move operations from right to left.
]=]
function Writer.Finalize(self: types.WriterData, b: buffer)
	local cursor = buffer.len(b) * 8

	for _, v in self._bitQueue do
		if v.z then
			cursor -= v.x
			buffer.writebits(b, cursor, v.x, reconstruct(v.y, v.z))
		elseif v.y ~= -1 then
			cursor -= v.x
			buffer.writebits(b, cursor, v.x, v.y)
		else
			cursor -= v.x
		end
	end
end

return Writer
