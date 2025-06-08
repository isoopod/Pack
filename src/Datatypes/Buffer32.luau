--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u32 = Reader.u32
local read_string = Reader.string

local write_string = Writer.string
local write_alloc = Writer.alloc
local write_u32 = Writer.u32

local datatype = table.freeze({
	Eval = "buffer32",
	Read = function(reader: types.ReaderData): buffer
		local len = read_u32(reader)
		return buffer.fromstring(read_string(reader, len))
	end,
	Write = function(writer: types.WriterData, value: buffer)
		local len, write = write_string(writer, buffer.tostring(value))

		write_alloc(writer, 4)
		write_u32(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
