--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u8 = Reader.u8
local read_string = Reader.string

local write_string = Writer.string
local write_alloc = Writer.alloc
local write_u8 = Writer.u8

local datatype = table.freeze({
	Eval = "s8",
	Read = function(reader: types.ReaderData): string
		local len = read_u8(reader)
		return read_string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = write_string(writer, value)

		write_alloc(writer, 1)
		write_u8(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
