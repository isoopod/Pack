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
	Eval = "Color3",
	Read = function(reader: types.ReaderData): Color3
		return Color3.fromRGB(read_u8(reader), read_u8(reader), read_u8(reader))
	end,
	Write = function(writer: types.WriterData, value: Color3)
		write_alloc(writer, 3)
		write_u8(writer, value.R * 255)
		write_u8(writer, value.G * 255)
		write_u8(writer, value.B * 255)
	end,
}) :: types.DatatypeInterface<Color3>

return datatype
