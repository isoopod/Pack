--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "R3",
	Read = function(reader: types.ReaderData): Region3
		local min: Vector3 = vector.create(Reader.f32(reader), Reader.f32(reader), Reader.f32(reader)) :: any
		local max: Vector3 = vector.create(Reader.f32(reader), Reader.f32(reader), Reader.f32(reader)) :: any

		return Region3.new(min, max)
	end,
	Write = function(writer: types.WriterData, value: Region3)
		local position = value.CFrame.Position
		local size = value.Size

		local min = position - size
		local max = position + size

		Writer.alloc(writer, 24)
		Writer.f32(writer, min.X)
		Writer.f32(writer, min.Y)
		Writer.f32(writer, min.Z)
		Writer.f32(writer, max.X)
		Writer.f32(writer, max.Y)
		Writer.f32(writer, max.Z)
	end,
}) :: types.DatatypeInterface<Region3>

return datatype
