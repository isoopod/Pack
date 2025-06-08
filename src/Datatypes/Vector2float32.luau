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
	Eval = "V2",
	Read = function(reader: types.ReaderData): Vector2
		return Vector2.new(read_f32(reader), read_f32(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		write_alloc(writer, 8)
		write_f32(writer, value.X)
		write_f32(writer, value.Y)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
