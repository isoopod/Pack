--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_i8 = Reader.i8

local write_alloc = Writer.alloc
local write_i8 = Writer.i8

local datatype = table.freeze({
	Eval = "i8",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		return read_i8(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 1)
		write_i8(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
