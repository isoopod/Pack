--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_f32 = Reader.f32

local write_alloc = Writer.alloc
local write_f32 = Writer.f32

local datatype = table.freeze({
	Eval = "f32",
	Read = function(reader: types.ReaderData): number
		return read_f32(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 4)
		write_f32(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
