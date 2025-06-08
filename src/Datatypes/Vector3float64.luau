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
	Eval = "V3f64",
	Read = function(reader: types.ReaderData): vector
		return vector.create(read_f64(reader), read_f64(reader), read_f64(reader))
	end,
	Write = function(writer: types.WriterData, value: vector)
		write_alloc(writer, 24)
		write_f64(writer, value.x)
		write_f64(writer, value.y)
		write_f64(writer, value.z)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
