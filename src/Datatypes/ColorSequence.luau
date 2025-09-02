--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u8 = Reader.u8
local read_u16 = Reader.u16

local write_alloc = Writer.alloc
local write_u8 = Writer.u8
local write_u16 = Writer.u16

local DEBUG = types.DEBUG
local PRECISION = 0xffff

-- Potential improvement: If there are only two repeated keypoints, only write one.
-- Low priority as that is already a poor use of ColorSequence.

return function(valueType: types.DatatypeInterface<Color3>): types.DatatypeInterface<ColorSequence>
	local read, write = valueType.Read, valueType.Write

	assert(valueType.Len, "ColorSequence valueType must be a numeric datatype")
	if DEBUG then DEBUG.EnforceDatatype.AnyColor3(valueType) end

	return table.freeze({
		Eval = "ColorSequence",
		Len = 5 + valueType.len * 2, -- Minimum of 2 keypoints
		Of = valueType,
		Read = function(reader: types.ReaderData): ColorSequence
			local len = read_u8(reader)
			local array = table.create(len) :: { ColorSequenceKeypoint }

			for i = 1, len do
				local time = read_u16(reader) / PRECISION
				local value = read(reader)
				array[i] = ColorSequenceKeypoint.new(time, value)
			end

			return ColorSequence.new(array)
		end,
		Write = function(writer: types.WriterData, value: ColorSequence)
			local keypoints = value.Keypoints
			local len = #keypoints

			write_alloc(writer, 1 + len * 2) -- Allocate length for the length byte, and all time values
			write_u8(writer, len)

			for i = 1, len do
				local kp = keypoints[i]
				write_u16(writer, kp.Time * PRECISION)
				write(writer, kp.Value)
			end
		end,
	}) :: types.DatatypeInterface<ColorSequence>
end
