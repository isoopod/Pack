--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u16 = Writer.u16

local datatype = table.freeze({
	Eval = "BrickColor",
	Len = 2,
	Read = function(reader: types.ReaderData): BrickColor
		return BrickColor.new(read_u16(reader))
	end,
	Write = function(writer: types.WriterData, value: BrickColor)
		write_alloc(writer, 2)
		write_u16(writer, value.Number)
	end,
}) :: types.DatatypeInterface<BrickColor>

return datatype
