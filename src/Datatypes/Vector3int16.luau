--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_i16 = Reader.i16

local write_alloc = Writer.alloc
local write_i16 = Writer.i16

-- We are going to and from the vector class here, as the Vector3int16 is very slow in comparison.
local datatype = table.freeze({
	Eval = "V3i16",
	Len = 6,
	Read = function(reader: types.ReaderData): Vector3int16
		return Vector3int16.new(read_i16(reader), read_i16(reader), read_i16(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector3int16)
		write_alloc(writer, 6)
		write_i16(writer, value.X)
		write_i16(writer, value.Y)
		write_i16(writer, value.Z)
	end,
}) :: types.DatatypeInterface<Vector3int16>

return datatype
