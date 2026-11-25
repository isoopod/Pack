--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_f32 = Reader.f32

const write_alloc = Writer.alloc
const write_f32 = Writer.f32

const datatype = table.freeze({
	Eval = "R3",
	Len = 24,
	Read = function(reader: types.ReaderData): Region3
		const min: Vector3 = vector.create(read_f32(reader), read_f32(reader), read_f32(reader)) :: any
		const max: Vector3 = vector.create(read_f32(reader), read_f32(reader), read_f32(reader)) :: any

		return Region3.new(min, max)
	end,
	Write = function(writer: types.WriterData, value: Region3)
		const position = value.CFrame.Position
		const halfSize = value.Size / 2

		const min = position - halfSize
		const max = position + halfSize

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
