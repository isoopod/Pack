--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_f32 = Reader.f32
local read_i16 = Reader.i16

local write_alloc = Writer.alloc
local write_f32 = Writer.f32
local write_i16 = Writer.i16

local datatype = table.freeze({
	Eval = "UD",
	Read = function(reader: types.ReaderData): UDim
		return UDim.new(read_f32(reader), read_i16(reader))
	end,
	Write = function(writer: types.WriterData, value: UDim)
		write_alloc(writer, 6)
		write_f32(writer, value.Scale)
		write_i16(writer, value.Offset)
		-- For the vast majority of applications in Roblox, we can assume the absolute offset will be under
		-- 2^15, letting us get away with 6 bytes instead of 8 (UDim's use an i32 for offset normally)
		-- If greater precision is needed, it is not very hard to make a Dictionary with a float32 Scale and an int32 Offset
	end,
}) :: types.DatatypeInterface<UDim>

return datatype
