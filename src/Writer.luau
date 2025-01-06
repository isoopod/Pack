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

local Writer = {}
local WriterClass = { metatable = { __index = Writer } }

-- It is up to you to allocate fixed numbers of bytes for datatype writing. You can call this multiple times in a write funciton.
-- You do not need to do this for writing strings, as they dynamically allocate bytes.
function Writer.Alloc(self: _Writer, bytes: number)
	self._len += bytes
end

----
function Writer.u8(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writeu8(b, cursor, value)
		return 1
	end)
end

function Writer.u16(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writeu16(b, cursor, value)
		return 2
	end)
end

function Writer.u32(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writeu32(b, cursor, value)
		return 4
	end)
end

function Writer.i8(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writei8(b, cursor, value)
		return 1
	end)
end

function Writer.i16(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writei16(b, cursor, value)
		return 2
	end)
end

function Writer.i32(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writei32(b, cursor, value)
		return 4
	end)
end

function Writer.f32(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writef32(b, cursor, value)
		return 4
	end)
end

function Writer.f64(self: _Writer, value: number)
	table.insert(self._queue, function(b, cursor)
		buffer.writef64(b, cursor, value)
		return 8
	end)
end

-- NOTICE: This function will allocate automatically as strings are variable length
function Writer.string(self: _Writer, value: string, count: number?)
	local s = buffer.fromstring(value)
	local len = buffer.len(s)
	self._len += len
	table.insert(self._queue, function(b, cursor)
		buffer.copy(b, cursor, s, 0, count)
		s = nil :: any
		return len
	end)
end
----

-- Build the buffer from the writer and cleanup
function Writer.Finalize(self: _Writer): buffer
	local b = buffer.create(self._len)
	local cursor = 0

	for _, v in self._queue do
		cursor += v(b, cursor)
	end

	self:Destroy()

	return b
end

function Writer.Destroy(self: _Writer)
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end

function WriterClass.new(): types.Writer
	local self: _Writer = setmetatable({}, WriterClass.metatable) :: any

	self._len = 0
	self._queue = {}

	return self
end

return WriterClass
