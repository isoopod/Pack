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
	_queue: { (b: buffer, cursor: number) -> number },
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
	table.insert(self._queue, function(b, cursor)
		writeu8(b, cursor, value)
		return 1
	end)
end

function Writer.u16(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		writeu16(b, cursor, value)
		return 2
	end)
end

function Writer.u32(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		writeu32(b, cursor, value)
		return 4
	end)
end

function Writer.i8(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		writei8(b, cursor, value)
		return 1
	end)
end

function Writer.i16(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		writei16(b, cursor, value)
		return 2
	end)
end

function Writer.i32(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		writei32(b, cursor, value)
		return 4
	end)
end

function Writer.f32(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		writef32(b, cursor, value)
		return 4
	end)
end

function Writer.f64(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		writef64(b, cursor, value)
		return 8
	end)
end

-- NOTICE: This function will allocate automatically as strings are variable length
-- Returns the length of the string (in bytes) and a function to actually write it
function Writer.string(self: _Writer, value: string, count: number?): (number, () -> ())
	local s = fromstring(value)
	local blen = len(s)
	self._len += blen
	return blen, function()
		table.insert(self._queue, function(b, cursor)
			copy(b, cursor, s, 0, count)
			s = nil :: any
			return blen
		end)
	end
end

-- Used to push the cursor forwards by a variable number of bytes without writing anything
function Writer.noop(self: _Writer, length: number)
	table.insert(self._queue, function()
		return length
	end)
end
----

-- Build the buffer from the writer and cleanup
function Writer.Finalize(self: _Writer): buffer
	local b = create(self._len)
	local cursor = 0

	for _, v in self._queue do
		cursor += v(b, cursor)
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
