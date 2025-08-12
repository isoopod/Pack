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
	Eval = "u8",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		return read_u8(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 1)
		write_u8(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
