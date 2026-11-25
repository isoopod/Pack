--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_moveCursor = Reader.moveCursor
const read_peakRemainder = Reader.peekRemainder

const write_u8 = Writer.u8
const write_string = Writer.string
const write_alloc = Writer.alloc

const datatype = table.freeze({
	Eval = "sZ",
	Len = 1,
	Read = function(reader: types.ReaderData): string
		const remainder = buffer.tostring(read_peakRemainder(reader))

		-- string.find is by far the fastest way to find the first occurence of the null terminator.
		const nullIndex = string.find(remainder, "\0", 1, true)
		assert(nullIndex, "Malformed sZ: no null terminator found")

		const len = nullIndex - 1
		const value = string.sub(remainder, 1, len)
		read_moveCursor(reader, nullIndex)
		return value
	end,
	Write = function(writer: types.WriterData, value: string)
		const len = #value

		write_alloc(writer, len + 1)

		write_string(writer, value, len)
		write_u8(writer, 0) -- Null terminator (dont add to string directly as it would reallocate the string)
	end,
}) :: types.DatatypeInterface<string>

return datatype
