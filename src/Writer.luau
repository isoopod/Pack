--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local types = require(script.Parent.types)

type _Writer = types.Writer & {
	_len: number,
	_queue: { { any } },
}

local writeu8 = buffer.writeu8
local writeu16 = buffer.writeu16
local writeu32 = buffer.writeu32
local writei8 = buffer.writei8
local writei16 = buffer.writei16
local writei32 = buffer.writei32
local writef32 = buffer.writef32
local writef64 = buffer.writef64
-- selene: allow(incorrect_standard_library_use)
local writebits = buffer.writebits
local fromstring = buffer.fromstring

local len = buffer.len
local copy = buffer.copy
local create = buffer.create

local Writer = {}
local WriterClass = { metatable = { __index = Writer } }

-- It is up to you to allocate fixed numbers of bytes for datatype writing. You can call this multiple times in a write funciton.
-- You do not need to do this for writing strings, as they dynamically allocate bytes.
function Writer.alloc(self: _Writer, bytes: number)
	self._len += bytes
end

----
function Writer.u8(self: _Writer, value: number)
	table.insert(self._queue, { "u8", value })
end

function Writer.u16(self: _Writer, value: number)
	table.insert(self._queue, { "u16", value })
end

function Writer.u32(self: _Writer, value: number)
	table.insert(self._queue, { "u32", value })
end

function Writer.i8(self: _Writer, value: number)
	table.insert(self._queue, { "i8", value })
end

function Writer.i16(self: _Writer, value: number)
	table.insert(self._queue, { "i16", value })
end

function Writer.i32(self: _Writer, value: number)
	table.insert(self._queue, { "i32", value })
end

function Writer.nBitUint(self: _Writer, value: number, n: number, bitOffset: number)
	table.insert(self._queue, { "nBitUint", value, n, bitOffset })
end

function Writer.nBitInt(self: _Writer, value: number, n: number, bitOffset: number)
	table.insert(self._queue, { "nBitInt", value, n, bitOffset })
end

function Writer.f32(self: _Writer, value: number)
	table.insert(self._queue, { "f32", value })
end

function Writer.f64(self: _Writer, value: number)
	table.insert(self._queue, { "f64", value })
end

-- NOTICE: This function will allocate automatically as strings are variable length
-- Returns the length of the string (in bytes) and a function to actually write it
function Writer.string(self: _Writer, value: string, count: number?): (number, () -> ())
	local s = fromstring(value)
	local blen = math.clamp(len(s), 0, count or math.huge)
	self._len += blen
	return blen, function()
		table.insert(self._queue, { "string", s, blen, count })
	end
end

-- Pushes the cursor by delta bytes.
-- Warning: This does not prevent you from leaving buffer bounds.
function Writer.moveCursor(self: _Writer, delta: number)
	table.insert(self._queue, { "moveCursor", delta })
end
----

local WriteFunctions: { [string]: (buffer, number, ...any) -> number } = {}

function WriteFunctions.u8(b: buffer, cursor: number, value: number): number
	writeu8(b, cursor, value)
	return 1
end

function WriteFunctions.u16(b: buffer, cursor: number, value: number): number
	writeu16(b, cursor, value)
	return 2
end

function WriteFunctions.u32(b: buffer, cursor: number, value: number): number
	writeu32(b, cursor, value)
	return 4
end

function WriteFunctions.i8(b: buffer, cursor: number, value: number): number
	writei8(b, cursor, value)
	return 1
end

function WriteFunctions.i16(b: buffer, cursor: number, value: number): number
	writei16(b, cursor, value)
	return 2
end

function WriteFunctions.i32(b: buffer, cursor: number, value: number): number
	writei32(b, cursor, value)
	return 4
end

-- Require manual cursor movement afterwards
function WriteFunctions.nBitUint(b: buffer, cursor: number, value: number, n: number, bitOffset: number): number
	writebits(b, cursor * 8 + bitOffset, n, value)
	return 0
end

function WriteFunctions.nBitInt(b: buffer, cursor: number, value: number, n: number, bitOffset: number): number
	writebits(b, cursor * 8 + bitOffset, n, value < 0 and value + 2 ^ n or value)
	return 0
end
--//

function WriteFunctions.f32(b: buffer, cursor: number, value: number): number
	writef32(b, cursor, value)
	return 4
end

function WriteFunctions.f64(b: buffer, cursor: number, value: number): number
	writef64(b, cursor, value)
	return 8
end

function WriteFunctions.string(b: buffer, cursor: number, s: buffer, blen: number, count: number): number
	copy(b, cursor, s, 0, count)
	s = nil :: any
	return blen
end

function WriteFunctions.moveCursor(_, _, delta: number): number
	return delta
end

-- Build the buffer from the writer and cleanup
function Writer.Finalize(self: _Writer): buffer
	local b = create(self._len)
	local cursor = 0

	for i = 1, #self._queue do
		local v = self._queue[i]
		cursor += WriteFunctions[v[1]](b, cursor, unpack(v, 2))
	end

	return b
end

function WriterClass.new(): types.Writer
	local self: _Writer = setmetatable({}, WriterClass.metatable) :: any

	self._len = 0
	self._queue = {}

	return self
end

return WriterClass
