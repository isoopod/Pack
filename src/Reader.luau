--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local types = require(script.Parent.Types)

local readu8 = buffer.readu8
local readu16 = buffer.readu16
local readu32 = buffer.readu32
local readi8 = buffer.readi8
local readi16 = buffer.readi16
local readi32 = buffer.readi32
local readf32 = buffer.readf32
local readf64 = buffer.readf64
local readstring = buffer.readstring

local Reader = {}
local ReaderClass = { metatable = { __index = Reader } }

-- Make sure when you use this that it goes back to where its supposed to when you are done, and be careful not to go outside the buffer bounds
function Reader.moveCursor(self: types.Reader, delta: number): ()
	self.Cursor += delta
end

----
function Reader.u8(self: types.Reader): number
	local value = readu8(self._buffer, self.Cursor)
	self.Cursor += 1
	return value
end

function Reader.u16(self: types.Reader): number
	local value = readu16(self._buffer, self.Cursor)
	self.Cursor += 2
	return value
end

function Reader.u32(self: types.Reader): number
	local value = readu32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

function Reader.i8(self: types.Reader): number
	local value = readi8(self._buffer, self.Cursor)
	self.Cursor += 1
	return value
end

function Reader.i16(self: types.Reader): number
	local value = readi16(self._buffer, self.Cursor)
	self.Cursor += 2
	return value
end

function Reader.i32(self: types.Reader): number
	local value = readi32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

function Reader.f32(self: types.Reader): number
	local value = readf32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

function Reader.f64(self: types.Reader): number
	local value = readf64(self._buffer, self.Cursor)
	self.Cursor += 8
	return value
end

function Reader.string(self: types.Reader, count: number): string
	local value = readstring(self._buffer, self.Cursor, count)
	self.Cursor += count
	return value
end
----

function Reader.Destroy(self: types.Reader)
	setmetatable(self, nil)
	table.clear(self :: any)
	table.freeze(self :: {})
end

function ReaderClass.new(packet: buffer): types.Reader
	local self: types.Reader = setmetatable({}, ReaderClass.metatable) :: any

	self.Cursor = 0
	self._buffer = packet

	return self
end

return ReaderClass
