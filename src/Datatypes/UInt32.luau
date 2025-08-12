--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u32 = Reader.u32

local write_alloc = Writer.alloc
local write_u32 = Writer.u32

local datatype = table.freeze({
	Eval = "u32",
	Len = 4,
	Read = function(reader: types.ReaderData): number
		return read_u32(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 4)
		write_u32(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
