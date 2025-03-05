--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "V3",
	Read = function(reader: types.ReaderData): vector
		return vector.create(Reader.f32(reader), Reader.f32(reader), Reader.f32(reader))
	end,
	Write = function(writer: types.WriterData, value: vector)
		Writer.alloc(writer, 12)
		Writer.f32(writer, value.x)
		Writer.f32(writer, value.y)
		Writer.f32(writer, value.z)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
