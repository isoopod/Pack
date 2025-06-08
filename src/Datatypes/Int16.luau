--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_i16 = Reader.i16

local write_alloc = Writer.alloc
local write_i16 = Writer.i16

local datatype = table.freeze({
	Eval = "i16",
	Read = function(reader: types.ReaderData): number
		return read_i16(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 2)
		write_i16(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
