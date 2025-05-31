--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local min = math.min

local POW16 = 2 ^ 16
local POW32 = 2 ^ 32
local POW48 = 2 ^ 48
local POW53 = 2 ^ 53

local datatype = table.freeze({
	Eval = "u56",
	Read = function(reader: types.ReaderData): number
		-- Read in little-endian order
		local low32 = Reader.u32(reader)
		local mid16 = Reader.u16(reader)
		local top8 = Reader.u8(reader)

		-- raw = low32 + (mid16 << 32) + (top8 << 48)
		local raw = low32 + (mid16 * POW32) + (top8 * POW48)

		return raw
	end,
	Write = function(writer: types.WriterData, value: number)
		-- Doubles can only accurately represent integers up to 2^53
		local raw = min(value, POW53)

		local low32 = raw % POW32
		local mid16 = raw // POW32 % POW16
		local top8 = raw // POW48 % 256

		-- Write in little‐endian order
		Writer.alloc(writer, 7)
		Writer.u32(writer, low32)
		Writer.u16(writer, mid16)
		Writer.u8(writer, top8)
	end,
}) :: types.DatatypeInterface<number>

return datatype
