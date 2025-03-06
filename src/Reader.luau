--!native
--!strict
--!optimize 2

--Modules
local types = require(script.Parent.types)

--[=[
	@class Reader
	An internal ordered buffer reader library used to deserialize packets.  
	A reader instance is created with the .new constructor and modified by the library's functions.
]=]

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

--[=[
	@function moveCursor
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@param delta number -- How many bytes to move the cursor, can be negative to go backwards
	Manually moves the reader's cursor.  
	:::danger
	Does not prevent you from leaving buffer bounds.
	:::
]=]
function Reader.moveCursor(self: types.ReaderData, delta: number): ()
	self.Cursor += delta
end

----
--[=[
	@function u8
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@return number
	Reads an unsigned 8-bit integer from the buffer and moves the cursor forwards 1 byte.
]=]
function Reader.u8(self: types.ReaderData): number
	local value = readu8(self._buffer, self.Cursor)
	self.Cursor += 1
	return value
end

--[=[
	@function u16
	@within Reader
	@param self ReaderData -- A reader instance created with.new
	@return number
	Reads an unsigned 16-bit integer from the buffer and moves the cursor forwards 2 bytes.
]=]
function Reader.u16(self: types.ReaderData): number
	local value = readu16(self._buffer, self.Cursor)
	self.Cursor += 2
	return value
end

--[=[
	@function u32
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@return number
	Reads an unsigned 32-bit integer from the buffer and moves the cursor forwards 4 bytes.
]=]
function Reader.u32(self: types.ReaderData): number
	local value = readu32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

--[=[
	@function u8
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@return number
	Reads a signed 8-bit integer from the buffer and moves the cursor forwards 1 byte.
]=]
function Reader.i8(self: types.ReaderData): number
	local value = readi8(self._buffer, self.Cursor)
	self.Cursor += 1
	return value
end

--[=[
	@function i16
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@return number
	Reads a signed 16-bit integer from the buffer and moves the cursor forwards 2 bytes.
]=]
function Reader.i16(self: types.ReaderData): number
	local value = readi16(self._buffer, self.Cursor)
	self.Cursor += 2
	return value
end

--[=[
	@function i32
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@return number
	Reads a signed 32-bit integer from the buffer and moves the cursor forwards 4 bytes.
]=]
function Reader.i32(self: types.ReaderData): number
	local value = readi32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

--[=[
	@function nBitUint
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@param n number -- The length in bits of the integer
	@param bitOffset number -- The bit offset from the current cursor location [0 – 31]
	@return number
	Reads an unsigned integer of length `n` bits
	:::warning
	This function does not move the cursor after completing, so you will have to move it yourself with .moveCursor
	:::
]=]
function Reader.nBitUint(self: types.ReaderData, n: number, bitOffset: number): number
	return readbits(self._buffer, self.Cursor * 8 + bitOffset, n)
end

--[=[
	@function nBitInt
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@param n number -- The length in bits of the integer
	@param bitOffset number -- The bit offset from the current cursor location [0 – 31]
	@return number
	Reads a signed integer of length `n` bits
	:::warning
	This function does not move the cursor after completing, so you will have to move it yourself with .moveCursor
	:::
]=]
function Reader.nBitInt(self: types.ReaderData, n: number, bitOffset: number): number
	local value = readbits(self._buffer, self.Cursor * 8 + bitOffset, n)
	local sign = lshift(1, n - 1)

	if band(value, sign) ~= 0 then return value - 2 ^ n end
	return value
end

--[=[
	@function f32
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@return number
	Reads a 32-bit floating point number from the buffer and moves the cursor forwards 4 bytes.
]=]
function Reader.f32(self: types.ReaderData): number
	local value = readf32(self._buffer, self.Cursor)
	self.Cursor += 4
	return value
end

--[=[
	@function f64
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@return number
	Reads a 64-bit floating point number from the buffer and moves the cursor forwards 8 bytes.
]=]
function Reader.f64(self: types.ReaderData): number
	local value = readf64(self._buffer, self.Cursor)
	self.Cursor += 8
	return value
end

--[=[
	@function string
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@param count number -- The length of the string in bytes
	@return string
	Reads a string of length `count` bytes from the buffer and pushes the cursor `count` bytes forwards.
]=]
function Reader.string(self: types.ReaderData, count: number): string
	local value = readstring(self._buffer, self.Cursor, count)
	self.Cursor += count
	return value
end
----

--[=[
	@function new
	@within Reader
	@param packet buffer -- The packet the reader should be reading
	@return ReaderData
	@tag Constructor
	Creates a new reader instance from a written packet
]=]
function Reader.new(packet: buffer): types.ReaderData
	local self = {}

	self.Cursor = 0
	self._buffer = packet

	return self :: any
end

return table.freeze(Reader) :: types.Reader
