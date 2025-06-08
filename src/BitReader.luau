--!strict
--!native
--!optimize 2

local types = require(script.Parent.types)

--[=[
	@class BitReader
	Internal bit buffer reader library. Reads right to left, as the bitbuffer is appended to the end of the packet.
	A `BitReader` consumes a binary buffer from end to start, reading or skipping specific numbers of bits.
]=]

local Reader = {}

--[=[
	@function moveCursor
	@within BitReader
	@param delta number -- Number of bits to move the cursor by.
	Moves the read cursor to the left by the specified number of bits without reading.
	Used to skip over unused or reserved sections of the bit buffer.
]=]
function Reader.moveCursor(self: types.ReaderData, delta: number)
	self.BitCursor -= delta
end

--[=[
	@function read
	@within BitReader
	@param bits number -- Number of bits to read.
	@return number -- The value read from the buffer.
	Reads a value from the buffer by consuming the specified number of bits from right to left.
]=]
function Reader.read(self: types.ReaderData, bits: number)
	self.BitCursor -= bits
	return buffer.readbits(self._buffer, self.BitCursor, bits)
end

return Reader
