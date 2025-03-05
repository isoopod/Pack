--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "R3i16",
	Read = function(reader: types.ReaderData): Region3int16
		local min = Vector3int16.new(Reader.i16(reader), Reader.i16(reader), Reader.i16(reader))
		local max = Vector3int16.new(Reader.i16(reader), Reader.i16(reader), Reader.f32(reader))

		return Region3int16.new(min, max)
	end,
	Write = function(writer: types.WriterData, value: Region3int16)
		local min = value.Min
		local max = value.Max

		Writer.alloc(writer, 12)
		Writer.i16(writer, min.X)
		Writer.i16(writer, min.Y)
		Writer.i16(writer, min.Z)
		Writer.i16(writer, max.X)
		Writer.i16(writer, max.Y)
		Writer.i16(writer, max.Z)
	end,
}) :: types.DatatypeInterface<Region3int16>

return datatype
