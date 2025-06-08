--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u16 = Writer.u16

local datatype = table.freeze({
	Eval = "BrickColor",
	Read = function(reader: types.ReaderData): BrickColor
		return BrickColor.new(read_u16(reader))
	end,
	Write = function(writer: types.WriterData, value: BrickColor)
		write_alloc(writer, 2)
		write_u16(writer, value.Number)
	end,
}) :: types.DatatypeInterface<BrickColor>

return datatype
