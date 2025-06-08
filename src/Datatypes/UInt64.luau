--!strict
--!native
--!optimize 2

--[[ Note: 
	This is a perfect u64, as doubles lose integer precision after 2^53 + 1
	If true 64 bit ints are needed, you will have to integrate a custom datatype for an external 64 bit int library
	
	This is good enough for $int64 data found within roblox, such as assetids since roblox have made sure the numbers
	they use work correctly in luau
--]]

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u32 = Reader.u32

local write_alloc = Writer.alloc
local write_u32 = Writer.u32

local POW32 = 2 ^ 32

local datatype64 = table.freeze({
	Eval = "i64",

	Read = function(reader: types.ReaderData): number
		-- Read low and high segments
		local low = read_u32(reader)
		local high = read_u32(reader)

		-- Reconstruct signed 64-bit int
		return high * POW32 + low
	end,

	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 8)

		-- Split into low and high segments
		local low = value % POW32
		local high = value // POW32

		write_u32(writer, low)
		write_u32(writer, high)
	end,
}) :: types.DatatypeInterface<number>

return datatype64
