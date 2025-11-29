--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u8 = Reader.u8

local write_alloc = Writer.alloc
local write_u8 = Writer.u8

local TAU = 2 * math.pi
local TAU_INVERSE = 1 / TAU
local PRECISION = 0xff
local PRECISION_INVERSE = 1 / PRECISION

local datatype = table.freeze({
	Eval = "rad8",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		local byte = read_u8(reader)
		return byte * (PRECISION_INVERSE * TAU)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 1)

		value %= TAU
		write_u8(writer, (value * (TAU_INVERSE * PRECISION) + 0.5) // 1)
	end,
}) :: types.DatatypeInterface<number>

return datatype
