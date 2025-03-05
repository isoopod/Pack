--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local types = require(script.Parent.types)

local readu8 = buffer.readu8
local readu16 = buffer.readu16
local readu32 = buffer.readu32
local readi8 = buffer.readi8
local readi16 = buffer.readi16
local readi32 = buffer.readi32
local readf32 = buffer.readf32
local readf64 = buffer.readf64
-- selene: allow(incorrect_standard_library_use)
local readbits = buffer.readbits
local readstring = buffer.readstring

local lshift = bit32.lshift
local band = bit32.band

local Reader = {}

-- Make sure when you use this that it goes back to where its supposed to when you are done, and be careful not to go outside the buffer bounds
function Reader.moveCursor(self: types.ReaderData, delta: number): ()
	self.Cursor += delta
end

----
function Reader.u8(self: types.ReaderData): number
	local value = readu8(self._buffer, self.Cursor)
	self.Cursor += 1
	return value
end

function Reader.u16(self: types.ReaderData): number
	local value = readu16(self._buffer, self.Cursor)
	self.Cursor += 2
	return value
end

function Reader.u32(self: types.ReaderData): number
	local value = readu32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

function Reader.i8(self: types.ReaderData): number
	local value = readi8(self._buffer, self.Cursor)
	self.Cursor += 1
	return value
end

function Reader.i16(self: types.ReaderData): number
	local value = readi16(self._buffer, self.Cursor)
	self.Cursor += 2
	return value
end

function Reader.i32(self: types.ReaderData): number
	local value = readi32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

-- Requires manual cursor movement afterwards
function Reader.nBitUint(self: types.ReaderData, n: number, bitOffset: number): number
	return readbits(self._buffer, self.Cursor * 8 + bitOffset, n)
end

function Reader.nBitInt(self: types.ReaderData, n: number, bitOffset: number): number
	local value = readbits(self._buffer, self.Cursor * 8 + bitOffset, n)
	local sign = lshift(1, n - 1)

	if band(value, sign) ~= 0 then return value - 2 ^ n end
	return value
end
--//

function Reader.f32(self: types.ReaderData): number
	local value = readf32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

function Reader.f64(self: types.ReaderData): number
	local value = readf64(self._buffer, self.Cursor)
	self.Cursor += 8
	return value
end

function Reader.string(self: types.ReaderData, count: number): string
	local value = readstring(self._buffer, self.Cursor, count)
	self.Cursor += count
	return value
end
----

function Reader.new(packet: buffer): types.ReaderData
	local self = {}

	self.Cursor = 0
	self._buffer = packet

	return self :: any
end

return table.freeze(Reader) :: types.Reader
