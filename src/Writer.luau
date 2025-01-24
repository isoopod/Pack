--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local types = require(script.Parent.Types)

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

-- Used to push the cursor forwards by a variable number of bytes without writing anything
function Writer.noop(self: _Writer, length: number)
	table.insert(self._queue, { "noop", length })
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

function WriteFunctions.noop(_, _, length: number): number
	return length
end

-- Build the buffer from the writer and cleanup
function Writer.Finalize(self: _Writer): buffer
	local b = create(self._len)
	local cursor = 0

	for i = 1, #self._queue do
		local v = self._queue[i]
		cursor += WriteFunctions[v[1]](b, cursor, unpack(v, 2))
	end

	self:Destroy()

	return b
end

function Writer.Destroy(self: _Writer)
	setmetatable(self, nil)
	table.clear(self :: any)
	table.freeze(self :: {})
end

function WriterClass.new(): types.Writer
	local self: _Writer = setmetatable({}, WriterClass.metatable) :: any

	self._len = 0
	self._queue = {}

	return self
end

return WriterClass
