--!strict
--!native
--!optimize 2

--[[ Note: 
	This is a perfect i64, as doubles lose integer precision after 2^53 + 1
	If true 64 bit ints are needed, you will have to integrate a custom datatype for an external 64 bit int library
	
	This is good enough for $int64 data found within roblox, such as assetids since roblox have made sure the numbers
	they use work correctly in luau
--]]

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local POW32 = 2 ^ 32

local datatype64 = table.freeze({
	Eval = "i64",

	Read = function(reader: types.ReaderData): number
		-- Read low unsigned and high signed segments
		local low = Reader.u32(reader)
		local high = Reader.i32(reader)

		-- Reconstruct signed 64-bit int
		return high * POW32 + low
	end,

	Write = function(writer: types.WriterData, value: number)
		Writer.alloc(writer, 8)

		-- Split into low unsigned and high signed segments
		local low = value % POW32
		local high = value // POW32

		Writer.u32(writer, low)
		Writer.i32(writer, high)
	end,
}) :: types.DatatypeInterface<number>

return datatype64
