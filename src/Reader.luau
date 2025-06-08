--!native
--!strict
--!optimize 2

--Modules
local types = require("./types")

--[=[
	@class Reader
	An internal ordered buffer reader library used to deserialize packets.  
	A reader instance is created with the .new constructor and modified by the library's functions.
]=]

local NAN = 0 / 0
local INF = math.huge

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
	local value = buffer.readu8(self._buffer, self.Cursor)
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
	local value = buffer.readu16(self._buffer, self.Cursor)
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
	local value = buffer.readu32(self._buffer, self.Cursor)
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
	local value = buffer.readi8(self._buffer, self.Cursor)
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
	local value = buffer.readi16(self._buffer, self.Cursor)
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
	local value = buffer.readi32(self._buffer, self.Cursor)
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
	:::info
	This function does not move the cursor after completing, so you will have to move it yourself with .moveCursor
	:::
]=]
function Reader.nBitUint(self: types.ReaderData, n: number, bitOffset: number): number
	return buffer.readbits(self._buffer, self.Cursor * 8 + bitOffset, n)
end

--[=[
	@function nBitInt
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@param n number -- The length in bits of the integer
	@param bitOffset number -- The bit offset from the current cursor location [0 – 31]
	@return number
	Reads a signed integer of length `n` bits
	:::info
	This function does not move the cursor after completing, so you will have to move it yourself with .moveCursor
	:::
]=]
function Reader.nBitInt(self: types.ReaderData, n: number, bitOffset: number): number
	local value = buffer.readbits(self._buffer, self.Cursor * 8 + bitOffset, n)
	local sign = bit32.lshift(1, n - 1)

	if bit32.band(value, sign) ~= 0 then return value - 2 ^ n end
	return value
end

--[=[
	@function nBitFloat
	@within Reader
	@param self ReaderData -- A reader instance created with .new
	@param n number -- The length in bits of the floating point's exponent
	@param m number -- The length in bits of the floating point's mantissa
	@param bitOffset number -- The bit offset from the current cursor location [0 – 31]
	@return number
	Reads a custom signed floating point number with the exponent length `n` bits and mantissa length `m` bits
	:::info
	This function does not move the cursor after completing, so you will have to move it yourself with .moveCursor
	:::
	:::warning
	The sum of `n` and `m` should not be greater than `31 - bitOffset`.  
	:::
]=]
function Reader.nBitFloat(self: types.ReaderData, n: number, m: number, bitOffset: number): number
	local totalBits = 1 + n + m
	local combined = buffer.readbits(self._buffer, self.Cursor * 8 + bitOffset, totalBits)

	local sign = bit32.rshift(combined, n + m)
	local maxExponent = bit32.lshift(1, n) - 1
	local storedExponent = bit32.band(bit32.rshift(combined, m), maxExponent)
	local mantissa = bit32.band(combined, bit32.lshift(1, m) - 1)

	-- If the value is zero, return immediately.
	if storedExponent == 0 and mantissa == 0 then return 0 end

	-- Check for special cases: Infinity or NaN (exponent all ones)
	if storedExponent == maxExponent then
		if mantissa == 0 then
			return sign == 1 and -INF or INF
		else
			return NAN
		end
	end

	local bias = bit32.lshift(1, n - 1) - 1
	local exponent: number, value: number

	if storedExponent == 0 then
		-- Subnormal numbers: exponent is fixed at 1 - bias
		exponent = 1 - bias
		value = (mantissa / (2 ^ m)) * (2 ^ exponent)
	else
		-- Normalized numbers: restore the implicit leading 1
		exponent = storedExponent - bias
		value = (1 + (mantissa / (2 ^ m))) * (2 ^ exponent)
	end

	if sign == 1 then value = -value end

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
	local value = buffer.readf32(self._buffer, self.Cursor)
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
	local value = buffer.readf64(self._buffer, self.Cursor)
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
	local value = buffer.readstring(self._buffer, self.Cursor, count)
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
