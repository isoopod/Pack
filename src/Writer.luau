--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local types = require(script.Parent.types)

--[=[
	@class Writer
	An internal buffer builder used to serialize packets. Operations are added to a queue and the entire buffer will be created in one pass without needing to dynamically resize the buffer.  
	A writer instance is created with the .new constructor, and is modified with the library's functions.
]=]

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

--[=[
	@function alloc
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param bytes number -- The number of bytes to allocate
	Most Writer functions will not automatically allocate length to the buffer, instead opting to make this call as few times as possible when writing a datatype.  
	Functions that do allocate will be marked with the Allocating tag. Otherwise, figure out how many bytes you need to allocate and call Writer.alloc
]=]
function Writer.alloc(self: types.WriterData, bytes: number)
	self._len += bytes
end

----
--[=[
	@function u8
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**1 byte**  
	Orders an 8-bit unsigned integer to be written into the packet 
]=]
function Writer.u8(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_U8, value })
end

--[=[
	@function u16
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**2 bytes**  
	Orders a 16-bit unsigned integer to be written into the packet 
]=]
function Writer.u16(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_U16, value })
end

--[=[
	@function u32
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**4 bytes**  
	Orders a 32-bit unsigned integer to be written into the packet 
]=]
function Writer.u32(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_U32, value })
end

--[=[
	@function i8
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**1 bytes**  
	Orders an 8-bit signed integer to be written into the packet 
]=]
function Writer.i8(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_I8, value })
end

--[=[
	@function i16
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**2 bytes**  
	Orders a 16-bit signed integer to be written into the packet 
]=]
function Writer.i16(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_I16, value })
end

--[=[
	@function i32
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**4 bytes**  
	Orders a 32-bit signed integer to be written into the packet 
]=]
function Writer.i32(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_I32, value })
end

--[=[
	@function nBitUint
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	@param n number -- The length of the integer in bits
	@param bitOffset number -- The offset from the cursor in bits to start writing at [0 – 31]
	**`math.floor(n / 8) + 1` bytes**  
	Orders an unsigned `n`-bit integer to be written into the packet 
]=]
function Writer.nBitUint(self: types.WriterData, value: number, n: number, bitOffset: number)
	table.insert(self._queue, { OP_NBITU, value, n, bitOffset })
end

--[=[
	@function nBitInt
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	@param n number -- The length of the integer in bits
	@param bitOffset number -- The offset from the cursor in bits to start writing at [0 – 31]
	**`math.floor(n / 8) + 1` bytes**  
	Orders a signed `n`-bit integer to be written into the packet 
]=]
function Writer.nBitInt(self: types.WriterData, value: number, n: number, bitOffset: number)
	table.insert(self._queue, { OP_NBITI, value, n, bitOffset })
end

--[=[
	@function f32
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**4 bytes**  
	Orders a 32-bit floating point number to be written into the packet 
]=]
function Writer.f32(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_F32, value })
end

--[=[
	@function f64
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	**8 bytes**  
	Orders a 64-bit floating point number to be written into the packet 
]=]
function Writer.f64(self: types.WriterData, value: number)
	table.insert(self._queue, { OP_F64, value })
end

--[=[
	@function string
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value string -- The string you wish to write
	@param count number? -- Optional value denoting the maximum number of bytes to write
	@return number -- the length of the string in bytes
	@return () -> () -- A function that orders the wring to be written into the packet
	@tag Allocating

	Processes a string into a seperate buffer and allocates the byte length of the string (or if count is provided and smaller than blen, allocates `count` bytes)  
	Returns the amount of bytes allocated, and a function to insert the string write operation into the queue.  
	This is so the length of the string can be written before writing the string itself, for variable length strings.
]=]
function Writer.string(self: types.WriterData, value: string, count: number?): (number, () -> ())
	local s = fromstring(value)
	local blen = math.clamp(len(s), 0, count or math.huge)
	self._len += blen
	return blen, function()
		table.insert(self._queue, { OP_STR, s, blen, count })
	end
end

--[=[
	@function moveCursor
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param delta number -- How many bytes to move the cursor, can be negative to go backwards
	Manually moves the writer's cursor.  
	:::danger
	Does not prevent you from leaving buffer bounds.
	:::
]=]
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

--[=[
	@function Finalize
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@return buffer
	Creates a packet buffer from all queued operations in a single pass 
]=]
function Writer.Finalize(self: types.WriterData): buffer
	local b = create(self._len)
	local cursor = 0

	for i = 1, #self._queue do
		local v = self._queue[i]
		cursor += WriteFunctions[v[1]](b, cursor, unpack(v, 2))
	end

	return b
end

--[=[
	@function new
	@within Writer
	@return WriterData
	@tag Constructor
	Creates an empty writer instance
]=]
function Writer.new(): types.WriterData
	local self = {}

	self._len = 0
	self._queue = {}

	return self :: any
end

return table.freeze(Writer) :: types.Writer
