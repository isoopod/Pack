--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u8 = Reader.u8

local write_alloc = Writer.alloc
local write_u8 = Writer.u8

local datatype = table.freeze({
	Eval = "rad8",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		local byte = read_u8(reader)
		return byte * 0.024639942381096416 -- 0xff^-1 * 2pi
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 1)

		value %= 6.283185307179586 -- 2pi
		write_u8(writer, math.floor(value * 40.58451048843331 + 0.5)) -- 2pi^-1 * 0xff
	end,
}) :: types.DatatypeInterface<number>

return datatype
