--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u16 = Reader.u16
local read_string = Reader.string

local write_string = Writer.string
local write_alloc = Writer.alloc
local write_u16 = Writer.u16

local datatype = table.freeze({
	Eval = "buffer16",
	Read = function(reader: types.ReaderData): buffer
		local len = read_u16(reader)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local len, write = write_string(writer, buffer.tostring(value))

		write_alloc(writer, 2)
		write_u16(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
