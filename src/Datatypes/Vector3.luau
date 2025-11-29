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
	Eval = "V3",
	of = Float32,
	Len = 12,
	Read = function(reader: types.ReaderData): vector
		return vector.create(read_f32(reader), read_f32(reader), read_f32(reader))
	end,
	Write = function(writer: types.WriterData, value: vector)
		write_alloc(writer, 12)
		write_f32(writer, value.x)
		write_f32(writer, value.y)
		write_f32(writer, value.z)
	end,
}, {
	__call = function(_, valueType: types.DatatypeInterface<number>): types.DatatypeInterface<vector>
		local read, write = valueType.Read, valueType.Write
		if DEBUG then
			DEBUG.EnforceDatatype.AnyNumeric(valueType)
			if valueType.Eval == "f64" then warn("Float64 should not be used in a vector (vector precision is limited to Float32)") end
			-- There is a slight performance boost to using the default. If you have a use case for using `Pack.Vector3(Pack.Float32)` then do not worry about this.
			if valueType.Eval == "f32" then warn("Float32 is the default for Pack.Vector3 | Use `Pack.Vector3` instead of `Pack.Vector3(Pack.Float32)`") end
		end

		return table.freeze({
			Eval = "V3",
			of = valueType,
			Len = (valueType.Len or 0) * 3,
			Blen = valueType.BitLen and valueType.BitLen * 3,
			Read = function(reader: types.ReaderData): vector
				return vector.create(read(reader), read(reader), read(reader))
			end,
			Write = function(writer: types.WriterData, value: vector)
				write(writer, value.x)
				write(writer, value.y)
				write(writer, value.z)
			end,
		}) :: any
	end,
})) :: types.DatatypeInterface<vector>

return datatype
