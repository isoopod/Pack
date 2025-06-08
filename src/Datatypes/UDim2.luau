--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "UD2",
	Read = function(reader: types.ReaderData): UDim2
		return UDim2.new(Reader.f32(reader), Reader.i16(reader), Reader.f32(reader), Reader.i16(reader))
	end,
	Write = function(writer: types.WriterData, value: UDim2)
		Writer.alloc(writer, 12)
		Writer.f32(writer, value.X.Scale)
		Writer.i16(writer, value.X.Offset)
		Writer.f32(writer, value.Y.Scale)
		Writer.i16(writer, value.Y.Offset)
		-- For the vast majority of applications in Roblox, we can assume the absolute offset will be under
		-- 2^15, letting us get away with 12 bytes instead of 16 (UDim's use an i32 for offset normally)
		-- If greater precision is needed, it is not very hard to make a two Dictionaries with a float32 Scale and an int32 Offset
	end,
}) :: types.DatatypeInterface<UDim2>

return datatype
