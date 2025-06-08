--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_f64 = Reader.f64

local write_alloc = Writer.alloc
local write_f64 = Writer.f64

local datatype = table.freeze({
	Eval = "f64",
	Read = function(reader: types.ReaderData): number
		return read_f64(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 8)
		write_f64(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
