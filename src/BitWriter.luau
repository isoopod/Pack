--!strict
--!native
--!optimize 2

local types = require(script.Parent.types)

--[=[
	@class BitWriter
	Internal bit buffer builder library. Writes right to left, as the bitbuffer is appended to the end of the packet.
	A `BitWriter` accumulates a series of bit-level write and move operations, which are then packed into a binary buffer during finalisation.
]=]

local OP_WRITE = 1
local OP_MOVE = 2

local Writer = {}

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
	table.insert(self._bitQueue, vector.create(OP_WRITE, bits, value))
end

--[=[
	@function moveCursor
	@within BitWriter
	@param delta number -- Number of bits to move the cursor by.
	Moves the write cursor left by the given number of bits without writing any data.
	Useful for padding or skipping reserved sections of the buffer.
]=]
function Writer.moveCursor(self: types.WriterData, delta: number)
	table.insert(self._bitQueue, vector.create(OP_MOVE, delta))
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
			cursor -= v.y
			buffer.writebits(b, cursor, v.y, v.z)
		else
			cursor -= v.y
		end
	end
end

return Writer
