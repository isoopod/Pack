--!native
--!strict
--!optimize 2

-- Queues up write actions to the buffer can be written in a single pass at the end.
-- This is more efficient than concatenating onto the buffer each time we need to allocate.
-- Its the same idea as StringBuilder in Java.

--Modules
local BitWriter = require("./BitWriter")
local types = require("./types")

--[=[
	@class Writer
	An internal buffer builder used to serialize packets. Operations are added to a queue and the entire buffer will be created in one pass without needing to dynamically resize the buffer.  
	A writer instance is created with the .new constructor, and is modified with the library's functions.
]=]

local INF = math.huge

local OP_U8 = 1
local OP_U16 = 2
local OP_U32 = 3
local OP_I8 = 4
local OP_I16 = 5
local OP_I32 = 6
local OP_NBITU = 7
local OP_NBITI = 8
local OP_NBITF = 9
local OP_F32 = 10
local OP_F64 = 11
local OP_STR = 12
local OP_MOV = 13

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
	table.insert(self._queue, vector.create(OP_U8, value))
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
	table.insert(self._queue, vector.create(OP_U16, value))
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
	table.insert(self._queue, vector.create(OP_U16, value))
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
	table.insert(self._queue, vector.create(OP_I8, value))
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
	table.insert(self._queue, vector.create(OP_I16, value))
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
	table.insert(self._queue, vector.create(OP_I32, value))
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
	:::info
	nBitUint does not automatically move the writers cursor so you will have to call 
	Writer.moveCursor the appropriate number of bytes after writing a section of nBit numbers.
	:::
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
	:::info
	nBitInt does not automatically move the writers cursor so you will have to call 
	Writer.moveCursor the appropriate number of bytes after writing a section of nBit numbers.
	:::
]=]
function Writer.nBitInt(self: types.WriterData, value: number, n: number, bitOffset: number)
	table.insert(self._queue, { OP_NBITI, value, n, bitOffset })
end

--[=[
	@function nBitFloat
	@within Writer
	@param self WriterData -- A writer instance created with .new
	@param value number
	@param n number -- The length in bits of the floating point's exponent
	@param m number -- The length in bits of the floating point's mantissa
	@param bitOffset number -- The offset from the cursor in bits to start writing at [0 – 31]
	**`math.floor((1 + n + m) / 8) + 1` bytes**  
	Orders a signed `n`-bit integer to be written into the packet 
	:::info
	nBitFloat does not automatically move the writers cursor so you will have to call 
	Writer.moveCursor the appropriate number of bytes after writing a section of nBit numbers.
	:::
	:::warning
	The sum of `n` and `m` should not be greater than `31 - bitOffset`.  
	:::
]=]
function Writer.nBitFloat(self: types.WriterData, value: number, n: number, m: number, bitOffset: number)
	table.insert(self._queue, { OP_NBITF, value, n, m, bitOffset })
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
	table.insert(self._queue, vector.create(OP_F32, value))
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
	table.insert(self._queue, vector.create(OP_F64, value))
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
	local s = buffer.fromstring(value)
	local blen = math.clamp(buffer.len(s), 0, count or math.huge)
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
	table.insert(self._queue, vector.create(OP_MOV, delta))
end

function Writer.addRef(self: types.WriterData, ref: any)
	self.nRefs += 1
	self.refs[self.nRefs] = ref
end
----

local WriteFunctions: { (buffer, number, ...any) -> number } = {
	[OP_U8] = function(b: buffer, cursor: number, value: number): number
		buffer.writeu8(b, cursor, value)
		return 1
	end,
	[OP_U16] = function(b: buffer, cursor: number, value: number): number
		buffer.writeu16(b, cursor, value)
		return 2
	end,
	[OP_U32] = function(b: buffer, cursor: number, value: number): number
		buffer.writeu32(b, cursor, value)
		return 4
	end,
	[OP_I8] = function(b: buffer, cursor: number, value: number): number
		buffer.writei8(b, cursor, value)
		return 1
	end,
	[OP_I16] = function(b: buffer, cursor: number, value: number): number
		buffer.writei16(b, cursor, value)
		return 2
	end,
	[OP_I32] = function(b: buffer, cursor: number, value: number): number
		buffer.writei32(b, cursor, value)
		return 4
	end,
	[OP_NBITU] = function(b: buffer, cursor: number, value: number, n: number, bitOffset: number): number
		buffer.writebits(b, cursor * 8 + bitOffset, n, value)
		return 0
	end,
	[OP_NBITI] = function(b: buffer, cursor: number, value: number, n: number, bitOffset: number): number
		buffer.writebits(b, cursor * 8 + bitOffset, n, value < 0 and value + 2 ^ n or value)
		return 0
	end,
	-- TODO: dedicated half-float and float24 to optimize out bias calculation
	[OP_NBITF] = function(b: buffer, cursor: number, value: number, n: number, m: number, bitOffset: number): number
		-- n: number of exponent bits, m: number of mantissa bits.
		-- IEEE754: bias = 2^(n-1)-1
		local sign = 0
		local storedExponent = 0
		local mantissa = 0

		if value ~= value then
			-- NaN: IEEE 754 requires exponent to be all ones and mantissa non-zero.
			sign = 0
			storedExponent = (bit32.lshift(1, n)) - 1
			mantissa = 1 -- any non-zero value within m bits
		elseif value == INF or value == -INF then
			sign = value < 0 and 1 or 0
			storedExponent = (bit32.lshift(1, n)) - 1
			mantissa = 0
		else
			sign = value < 0 and 1 or 0
			local fAbs = math.abs(value)
			local bias = (bit32.lshift(1, n - 1)) - 1
			if fAbs == 0 then
				-- Zero is represented with all exponent and mantissa bits zero.
				storedExponent = 0
				mantissa = 0
			else
				-- Get normalized fraction and exponent via frexp.
				local fNormalized, exponent = math.frexp(fAbs)
				-- Adjust to have fNormalized in [1,2) and e = exponent - 1.
				local e = exponent - 1

				if e + bias >= 1 then
					-- Normalised number.
					storedExponent = e + bias
					-- The implicit bit is removed; fraction = fNormalized * 2 - 1.
					local fraction = (fNormalized * 2) - 1
					-- Round the mantissa to nearest.
					mantissa = math.floor(fraction * (2 ^ m) + 0.5)
					-- Handle rounding overflow.
					if mantissa >= (2 ^ m) then
						mantissa = 0
						storedExponent = storedExponent + 1
						if storedExponent >= (bit32.lshift(1, n)) - 1 then
							-- Overflow to infinity.
							storedExponent = (bit32.lshift(1, n)) - 1
							mantissa = 0
						end
					end
				else
					-- Subnormal number.
					storedExponent = 0
					-- For subnormals, the value is represented as:
					--   value = (mantissa / 2^m) * 2^(1 - bias)
					-- Rearranging gives:
					--   mantissa = fAbs * 2^(m + bias - 1)
					mantissa = math.floor(fAbs * (2 ^ (m + bias - 1)) + 0.5)
					-- Clamp to m bits.
					if mantissa >= (2 ^ m) then mantissa = (2 ^ m) - 1 end
				end
			end
		end

		-- Combine sign, exponent, and mantissa
		local combined = bit32.bor(bit32.lshift(sign, n + m), bit32.lshift(storedExponent, m), mantissa)

		buffer.writebits(b, cursor * 8 + bitOffset, 1 + n + m, combined)
		return 0
	end,
	[OP_F32] = function(b: buffer, cursor: number, value: number): number
		buffer.writef32(b, cursor, value)
		return 4
	end,
	[OP_F64] = function(b: buffer, cursor: number, value: number): number
		buffer.writef64(b, cursor, value)
		return 8
	end,
	[OP_STR] = function(b: buffer, cursor: number, s: buffer, blen: number, count: number): number
		buffer.copy(b, cursor, s, 0, count)
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
	local b = buffer.create(self._len + math.ceil(self._bitLen / 8))
	local cursor = 0

	for _, v in self._queue :: { any } do
		-- Slightly cheaper than type() call
		local x = v.x
		if x then
			-- This is a vectorized instruction
			cursor += WriteFunctions[x](b, cursor, v.y)
		else
			cursor += WriteFunctions[v[1]](b, cursor, unpack(v, 2))
		end
	end

	-- Build the reserved bit buffer at the end of the packet
	BitWriter.Finalize(self, b)

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

	self.nRefs = 0

	self._len = 0
	self._queue = {}

	self._bitLen = 0
	self._bitQueue = {}

	return self :: any
end

return table.freeze(Writer) :: types.Writer
