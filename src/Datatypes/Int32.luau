--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_i32 = Reader.i32

local write_alloc = Writer.alloc
local write_i32 = Writer.i32

local datatype = table.freeze({
	Eval = "i32",
	Read = function(reader: types.ReaderData): number
		return read_i32(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 4)
		write_i32(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
