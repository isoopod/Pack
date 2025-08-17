--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_string = Reader.string

local write_alloc = Writer.alloc
local write_stringFixed = Writer.stringFixed

local DEBUG = types.DEBUG

return function(length: number): types.DatatypeInterface<string>
	return table.freeze({
		Eval = "string",
		Len = length,
		Read = function(reader: types.ReaderData): string
			return read_string(reader, length)
		end,
		Write = function(writer: types.WriterData, value: string)
			if DEBUG then assert(#value == length, "stringFixed expects written string length (in bytes) to match the allocated length.") end
			write_alloc(writer, length)
			write_stringFixed(writer, value, length)
		end,
	}) :: types.DatatypeInterface<string>
end
