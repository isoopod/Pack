--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "R3i16",
	Read = function(Reader: types.Reader): Region3int16
		local min = Vector3int16.new(Reader:i16(), Reader:i16(), Reader:i16())
		local max = Vector3int16.new(Reader:i16(), Reader:i16(), Reader:f32())

		return Region3int16.new(min, max)
	end,
	Write = function(Writer: types.Writer, value: Region3int16)
		local min = value.Min
		local max = value.Max

		Writer:alloc(12)
		Writer:i16(min.X)
		Writer:i16(min.Y)
		Writer:i16(min.Z)
		Writer:i16(max.X)
		Writer:i16(max.Y)
		Writer:i16(max.Z)
	end,
}) :: types.DatatypeInterface<Region3int16>

return datatype
