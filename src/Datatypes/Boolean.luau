--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u8 = Reader.u8

local write_alloc = Writer.alloc
local write_u8 = Writer.u8

local datatype = table.freeze({
	Eval = "bool",
	Read = function(reader: types.ReaderData): boolean
		return read_u8(reader) == 1
	end,
	Write = function(writer: types.WriterData, value: boolean)
		write_alloc(writer, 1)
		write_u8(writer, value and 1 or 0)
	end,
}) :: types.DatatypeInterface<boolean>

return datatype
