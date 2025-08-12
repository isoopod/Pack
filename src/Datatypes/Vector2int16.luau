--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_i16 = Reader.i16

local write_alloc = Writer.alloc
local write_i16 = Writer.i16

-- Use Vector2 directly, since its nicer to work with
local datatype = table.freeze({
	Eval = "V2i16",
	Len = 4,
	Read = function(reader: types.ReaderData): Vector2
		return Vector2.new(read_i16(reader), read_i16(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		write_alloc(writer, 4)
		write_i16(writer, value.X)
		write_i16(writer, value.Y)
	end,
}) :: types.DatatypeInterface<Vector2>

return datatype
