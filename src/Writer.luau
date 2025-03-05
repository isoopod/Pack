--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local types = require(script.Parent.types)

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

local OP_U8 = 1
local OP_U16 = 2
local OP_U32 = 3
local OP_I8 = 4
local OP_I16 = 5
local OP_I32 = 6
local OP_NBITU = 7
local OP_NBITI = 8
local OP_F32 = 9
local OP_F64 = 10
local OP_STR = 11
local OP_MOV = 12

local Writer = {}

-- It is up to you to allocate fixed numbers of bytes for datatype writing. You can call this multiple times in a write funciton.
-- You do not need to do this for writing strings, as they dynamically allocate bytes.
function Writer.alloc(self: types.WriterData, bytes: number)
	self._len += bytes
end

----
function Writer.u8(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_U8, value })
end

function Writer.u16(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_U16, value })
end

function Writer.u32(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_U32, value })
end

function Writer.i8(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_I8, value })
end

function Writer.i16(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_I16, value })
end

function Writer.i32(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_I32, value })
end

function Writer.nBitUint(self: types.WriterData, value: number, n: number, bitOffset: number)
	table.insert(self._queue, { OP_NBITU, value, n, bitOffset })
end

function Writer.nBitInt(self: types.WriterData, value: number, n: number, bitOffset: number)
	table.insert(self._queue, { OP_NBITI, value, n, bitOffset })
end

function Writer.f32(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_F32, value })
end

function Writer.f64(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_F64, value })
end

-- NOTICE: This function will allocate automatically as strings are variable length
-- Returns the length of the string (in bytes) and a function to actually write it
function Writer.string(self: types.WriterData, value: string, count: number?): (number, () -> ())
	local s = fromstring(value)
	local blen = math.clamp(len(s), 0, count or math.huge)
	self._len += blen
	return blen, function()
		table.insert(self._queue, { OP_STR, s, blen, count })
	end
end

-- Pushes the cursor by delta bytes.
-- Warning: This does not prevent you from leaving buffer bounds.
function Writer.moveCursor(self: types.WriterData, delta: number)
	table.insert(self._queue, { OP_MOV, delta })
end
----

local WriteFunctions: { (buffer, number, ...any) -> number } = {
	[OP_U8] = function(b: buffer, cursor: number, value: number): number
		writeu8(b, cursor, value)
		return 1
	end,
	[OP_U16] = function(b: buffer, cursor: number, value: number): number
		writeu16(b, cursor, value)
		return 2
	end,
	[OP_U32] = function(b: buffer, cursor: number, value: number): number
		writeu32(b, cursor, value)
		return 4
	end,
	[OP_I8] = function(b: buffer, cursor: number, value: number): number
		writei8(b, cursor, value)
		return 1
	end,
	[OP_I16] = function(b: buffer, cursor: number, value: number): number
		writei16(b, cursor, value)
		return 2
	end,
	[OP_I32] = function(b: buffer, cursor: number, value: number): number
		writei32(b, cursor, value)
		return 4
	end,
	[OP_NBITU] = function(b: buffer, cursor: number, value: number, n: number, bitOffset: number): number
		writebits(b, cursor * 8 + bitOffset, n, value)
		return 0
	end,
	[OP_NBITI] = function(b: buffer, cursor: number, value: number, n: number, bitOffset: number): number
		writebits(b, cursor * 8 + bitOffset, n, value < 0 and value + 2 ^ n or value)
		return 0
	end,
	[OP_F32] = function(b: buffer, cursor: number, value: number): number
		writef32(b, cursor, value)
		return 4
	end,
	[OP_F64] = function(b: buffer, cursor: number, value: number): number
		writef64(b, cursor, value)
		return 8
	end,
	[OP_STR] = function(b: buffer, cursor: number, s: buffer, blen: number, count: number): number
		copy(b, cursor, s, 0, count)
		s = nil :: any
		return blen
	end,
	[OP_MOV] = function(_, _, delta: number): number
		return delta
	end,
}

-- Build the buffer from the writer and cleanup
function Writer.Finalize(self: types.WriterData): buffer
	local b = create(self._len)
	local cursor = 0

	for i = 1, #self._queue do
		local v = self._queue[i]
		cursor += WriteFunctions[v[1]](b, cursor, unpack(v, 2))
	end

	return b
end

function Writer.new(): types.WriterData
	local self = {}

	self._len = 0
	self._queue = {}

	return self :: any
end

return table.freeze(Writer) :: types.Writer
