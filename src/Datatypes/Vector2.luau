--!native
--!optimize 2

const Float32 = require(script.Parent.Float32)
const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_f32 = Reader.f32

const write_alloc = Writer.alloc
const write_f32 = Writer.f32

const DEBUG = types.DEBUG

const default = table.freeze({
	Eval = "V2",
	of = Float32,
	Len = 8,
	Read = function(reader: types.ReaderData): Vector2
		return Vector2.new(read_f32(reader), read_f32(reader))
	end,
	Write = function(writer: types.WriterData, value: Vector2)
		write_alloc(writer, 8)
		write_f32(writer, value.X)
		write_f32(writer, value.Y)
	end,
}) :: types.DatatypeInterface<Vector2>

return function(valueType: types.DatatypeInterface<number>?): types.DatatypeInterface<Vector2>
	if not valueType then return default end

	const read, write = valueType.Read, valueType.Write
	if DEBUG then
		DEBUG.EnforceDatatype.AnyNumeric(valueType)
		if valueType.Eval == "f64" then warn("Float64 should not be used in a vector (vector precision is limited to Float32)") end
		-- There is a slight performance boost to using the default. If you have a use case for using `Pack.Vector2(Pack.Float32)` then do not worry about this.
		if valueType.Eval == "f32" then warn("Float32 is the default for Pack.Vector2 | Use `Pack.Vector2` instead of `Pack.Vector2(Pack.Float32)`") end
	end

	return table.freeze({
		Eval = "V2",
		of = valueType,
		Len = (valueType.Len or 0) * 2,
		Blen = valueType.BitLen and valueType.BitLen * 2,
		Read = function(reader: types.ReaderData): Vector2
			return Vector2.new(read(reader), read(reader))
		end,
		Write = function(writer: types.WriterData, value: Vector2)
			write(writer, value.X)
			write(writer, value.Y)
		end,
	}) :: any
end
