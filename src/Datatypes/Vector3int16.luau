--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

-- We are going to and from the vector class here, as the Vector3int16 is very slow in comparison.
local datatype = table.freeze({
	Eval = "V3i16",
	Read = function(reader: types.ReaderData): vector
		return vector.create(Reader.i16(reader), Reader.i16(reader), Reader.i16(reader))
	end,
	Write = function(writer: types.WriterData, value: vector)
		Writer.alloc(writer, 6)
		Writer.i16(writer, value.x)
		Writer.i16(writer, value.y)
		Writer.i16(writer, value.z)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
