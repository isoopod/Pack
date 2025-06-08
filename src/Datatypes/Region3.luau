--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_f32 = Reader.f32

local write_alloc = Writer.alloc
local write_f32 = Writer.f32

local datatype = table.freeze({
	Eval = "R3",
	Read = function(reader: types.ReaderData): Region3
		local min: Vector3 = vector.create(read_f32(reader), read_f32(reader), read_f32(reader)) :: any
		local max: Vector3 = vector.create(read_f32(reader), read_f32(reader), read_f32(reader)) :: any

		return Region3.new(min, max)
	end,
	Write = function(writer: types.WriterData, value: Region3)
		local position = value.CFrame.Position
		local halfSize = value.Size / 2

		local min = position - halfSize
		local max = position + halfSize

		write_alloc(writer, 24)
		write_f32(writer, min.X)
		write_f32(writer, min.Y)
		write_f32(writer, min.Z)
		write_f32(writer, max.X)
		write_f32(writer, max.Y)
		write_f32(writer, max.Z)
	end,
}) :: types.DatatypeInterface<Region3>

return datatype
