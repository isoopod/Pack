--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_f64 = Reader.f64

local write_alloc = Writer.alloc
local write_f64 = Writer.f64

local datatype = table.freeze({
	Eval = "V2f64",
	Read = function(reader: types.ReaderData): Vector2
		return Vector2.new(read_f64(reader), read_f64(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		write_alloc(writer, 16)
		write_f64(writer, value.X)
		write_f64(writer, value.Y)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
