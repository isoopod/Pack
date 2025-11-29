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
	Eval = "buffer24",
	Len = 3,
	Read = function(reader: types.ReaderData): buffer
		local len = read_nBitUint(reader, 24, 0)
		read_moveCursor(reader, 3)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local s = buffer.tostring(value)
		local len = #s

		write_alloc(writer, len + 3)
		write_nBitUint(writer, len, 24, 0)
		write_moveCursor(writer, 3)

		write_string(writer, s, len)
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
