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
	Eval = "s16",
	Len = 2,
	Read = function(reader: types.ReaderData): string
		local len = read_u16(reader)
		return read_string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = write_string(writer, value)

		write_alloc(writer, 2)
		write_u16(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
