--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_moveCursor = Reader.moveCursor
local read_peakRemainder = Reader.peekRemainder

local write_u8 = Writer.u8
local write_string = Writer.string
local write_alloc = Writer.alloc

local datatype = table.freeze({
	Eval = "sZ",
	Len = 1,
	Read = function(reader: types.ReaderData): string
		local remainder = buffer.tostring(read_peakRemainder(reader))

		-- string.find is by far the fastest way to find the first occurence of the null terminator.
		local nullIndex = string.find(remainder, "/0", 1, true)
		assert(nullIndex, "Malformed sZ: no null terminator found")

		local len = nullIndex - 1
		local value = string.sub(remainder, 1, len)
		read_moveCursor(reader, nullIndex)
		return value
	end,
	Write = function(writer: types.WriterData, value: string)
		local len = #value

		write_alloc(writer, len + 1)

		write_string(writer, value, len)
		write_u8(writer, 0) -- Null terminator (dont add to string directly as it would reallocate the string)
	end,
}) :: types.DatatypeInterface<string>

return datatype
