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
	Eval = "s32",
	Len = 4,
	Read = function(reader: types.ReaderData): string
		local len = read_u32(reader)
		return read_string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = write_string(writer, value)

		write_alloc(writer, 4)
		write_u32(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
