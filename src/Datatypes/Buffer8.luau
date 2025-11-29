--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u8 = Reader.u8
local read_string = Reader.string

local write_string = Writer.string
local write_alloc = Writer.alloc
local write_u8 = Writer.u8

local datatype = table.freeze({
	Eval = "buffer8",
	Len = 1,
	Read = function(reader: types.ReaderData): buffer
		local len = read_u8(reader)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local s = buffer.tostring(value)
		local len = #s

		write_alloc(writer, len + 1)
		write_u8(writer, len)

		write_string(writer, s, len)
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
