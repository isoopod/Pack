--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u16 = Writer.u16

local PRECISION = 0xffff

local datatype = table.freeze({
	Eval = "frac",
	Len = 2,
	Read = function(reader: types.ReaderData): number
		return read_u16(reader) / PRECISION
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 2)
		write_u16(writer, math.floor(value * PRECISION + 0.5))
	end,
}) :: types.DatatypeInterface<number>

return datatype
