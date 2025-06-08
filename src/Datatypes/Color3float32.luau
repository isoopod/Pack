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
	Eval = "Color3Raw",
	Read = function(reader: types.ReaderData): Color3
		return Color3.new(read_f32(reader), read_f32(reader), read_f32(reader))
	end,
	Write = function(writer: types.WriterData, value: Color3)
		write_alloc(writer, 12)
		write_f32(writer, value.R)
		write_f32(writer, value.G)
		write_f32(writer, value.B)
	end,
}) :: types.DatatypeInterface<Color3>

return datatype
