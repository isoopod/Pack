--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "R3",
	Read = function(Reader: types.Reader): Region3
		local min: Vector3 = vector.create(Reader:f32(), Reader:f32(), Reader:f32()) :: any
		local max: Vector3 = vector.create(Reader:f32(), Reader:f32(), Reader:f32()) :: any

		return Region3.new(min, max)
	end,
	Write = function(Writer: types.Writer, value: Region3)
		local position = value.CFrame.Position
		local size = value.Size

		local min = position - size
		local max = position + size

		Writer:alloc(24)
		Writer:f32(min.X)
		Writer:f32(min.Y)
		Writer:f32(min.Z)
		Writer:f32(max.X)
		Writer:f32(max.Y)
		Writer:f32(max.Z)
	end,
}) :: types.DatatypeInterface<Region3>

return datatype
