--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_nBitFloat = Reader.nBitFloat
local read_moveCursor = Reader.moveCursor

local write_alloc = Writer.alloc
local write_nBitFloat = Writer.nBitFloat
local write_moveCursor = Writer.moveCursor

local datatype = table.freeze({
	Eval = "f16",
	Len = 2,
	Read = function(reader: types.ReaderData): number
		local value = read_nBitFloat(reader, 5, 10, 0)
		read_moveCursor(reader, 2)
		return value
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 2)

		write_nBitFloat(writer, value, 5, 10, 0)
		write_moveCursor(writer, 2)
	end,
}) :: types.DatatypeInterface<number>

return datatype
