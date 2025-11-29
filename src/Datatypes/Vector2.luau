--!native
--!optimize 2

local Float32 = require(script.Parent.Float32)
local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_f32 = Reader.f32

local write_alloc = Writer.alloc
local write_f32 = Writer.f32

local DEBUG = types.DEBUG

local datatype = table.freeze(setmetatable({
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
}, {
	__call = function(_, valueType: types.DatatypeInterface<number>): types.DatatypeInterface<Vector2>
		local read, write = valueType.Read, valueType.Write
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
	end,
})) :: types.DatatypeInterface<Vector2>

return datatype
