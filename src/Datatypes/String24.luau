--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_nBitUint = Reader.nBitUint
local read_moveCursor = Reader.moveCursor
local read_string = Reader.string

local write_string = Writer.string
local write_alloc = Writer.alloc
local write_nBitUint = Writer.nBitUint
local write_moveCursor = Writer.moveCursor

local datatype = table.freeze({
	Eval = "s32",
	Read = function(reader: types.ReaderData): string
		local len = read_nBitUint(reader, 24, 0)
		read_moveCursor(reader, 3)
		return read_string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = write_string(writer, value)

		write_alloc(writer, 3)
		write_nBitUint(writer, len, 24, 0)
		write_moveCursor(writer, 3)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
