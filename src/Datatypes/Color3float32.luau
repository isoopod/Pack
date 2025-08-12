--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_f32 = Reader.f32

local write_alloc = Writer.alloc
local write_f32 = Writer.f32

local datatype = table.freeze({
	Eval = "Color3Raw",
	Len = 12,
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
