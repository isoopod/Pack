--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u32 = Reader.u32
local read_string = Reader.string

local write_string = Writer.string
local write_alloc = Writer.alloc
local write_u32 = Writer.u32

local datatype = table.freeze({
	Eval = "buffer32",
	Len = 4,
	Read = function(reader: types.ReaderData): buffer
		local len = read_u32(reader)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local s = buffer.tostring(value)
		local len = #s

		write_alloc(writer, len + 4)
		write_u32(writer, len)

		write_string(writer, s, len)
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
