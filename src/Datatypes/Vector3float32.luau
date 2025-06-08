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
	Eval = "V3",
	Read = function(reader: types.ReaderData): vector
		return vector.create(read_f32(reader), read_f32(reader), read_f32(reader))
	end,
	Write = function(writer: types.WriterData, value: vector)
		write_alloc(writer, 12)
		write_f32(writer, value.x)
		write_f32(writer, value.y)
		write_f32(writer, value.z)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
