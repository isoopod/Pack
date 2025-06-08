--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_i16 = Reader.i16

local write_alloc = Writer.alloc
local write_i16 = Writer.i16

local datatype = table.freeze({
	Eval = "R3i16",
	Read = function(reader: types.ReaderData): Region3int16
		local min = Vector3int16.new(read_i16(reader), read_i16(reader), read_i16(reader))
		local max = Vector3int16.new(read_i16(reader), read_i16(reader), read_i16(reader))

		return Region3int16.new(min, max)
	end,
	Write = function(writer: types.WriterData, value: Region3int16)
		local min = value.Min
		local max = value.Max

		write_alloc(writer, 12)
		write_i16(writer, min.X)
		write_i16(writer, min.Y)
		write_i16(writer, min.Z)
		write_i16(writer, max.X)
		write_i16(writer, max.Y)
		write_i16(writer, max.Z)
	end,
}) :: types.DatatypeInterface<Region3int16>

return datatype
