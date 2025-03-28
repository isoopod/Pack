--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "V3f64",
	Read = function(reader: types.ReaderData): vector
		return vector.create(Reader.f64(reader), Reader.f64(reader), Reader.f64(reader))
	end,
	Write = function(writer: types.WriterData, value: vector)
		Writer.alloc(writer, 24)
		Writer.f64(writer, value.x)
		Writer.f64(writer, value.y)
		Writer.f64(writer, value.z)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
