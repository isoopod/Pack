--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u16 = Writer.u16

local datatype = table.freeze({
	Eval = "rad16",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		local byte = read_u16(reader)
		return byte * 0.00009587526218325454 -- 0xffff^-1 * 2pi
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 2)

		value %= math.pi * 2
		write_u16(writer, math.floor(value * 10430.219195527361 + 0.5)) -- 2pi^-1 * 0xffff
	end,
}) :: types.DatatypeInterface<number>

return datatype
