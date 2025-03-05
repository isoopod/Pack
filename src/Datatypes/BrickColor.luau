--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "BrickColor",
	Read = function(reader: types.ReaderData): BrickColor
		return BrickColor.new(Reader.u16(reader))
	end,
	Write = function(writer: types.WriterData, value: BrickColor)
		Writer.alloc(writer, 2)
		Writer.u16(writer, value.Number)
	end,
}) :: types.DatatypeInterface<BrickColor>

return datatype
