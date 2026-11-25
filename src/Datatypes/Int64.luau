--!native
--!optimize 2

--[[ Note: 
	This is a perfect i64, as doubles lose integer precision after 2^53 + 1
	If true 64 bit ints are needed, you will have to integrate a custom datatype for an external 64 bit int library
	
	This is good enough for $int64 data found within roblox, such as assetids since roblox have made sure the numbers
	they use work correctly in luau
--]]

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u32 = Reader.u32
const read_i32 = Reader.i32

const write_alloc = Writer.alloc
const write_u32 = Writer.u32
const write_i32 = Writer.i32

const POW32 = 2 ^ 32

const datatype64 = table.freeze({
	Eval = "i64",
	Len = 8,

	Read = function(reader: types.ReaderData): number
		-- Read low unsigned and high signed segments
		const low = read_u32(reader)
		const high = read_i32(reader)

		-- Reconstruct signed 64-bit int
		return high * POW32 + low
	end,

	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 8)

		-- Split into low unsigned and high signed segments
		const low = value % POW32
		const high = value // POW32

		write_u32(writer, low)
		write_i32(writer, high)
	end,
}) :: types.DatatypeInterface<number>

return datatype64
