--!strict
--!native
--!optimize 2

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_i16 = Reader.i16

local write_alloc = Writer.alloc
local write_i16 = Writer.i16

-- We are going to and from the vector class here, as the Vector3int16 is very slow in comparison.
local datatype = table.freeze({
	Eval = "V3i16",
	Read = function(reader: types.ReaderData): vector
		return vector.create(read_i16(reader), read_i16(reader), read_i16(reader))
	end,
	Write = function(writer: types.WriterData, value: vector)
		write_alloc(writer, 6)
		write_i16(writer, value.x)
		write_i16(writer, value.y)
		write_i16(writer, value.z)
	end,
}) :: types.DatatypeInterface<vector>

return datatype
