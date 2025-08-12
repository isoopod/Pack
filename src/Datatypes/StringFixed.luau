--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_string = Reader.string

local write_string = Writer.string

local DEBUG = types.DEBUG

return function(length: number): types.DatatypeInterface<string>
	return table.freeze({
		Eval = "string",
		Len = length,
		Read = function(reader: types.ReaderData): string
			return read_string(reader, length)
		end,
		Write = function(writer: types.WriterData, value: string)
			local len, write = write_string(writer, value)
			if DEBUG then assert(len == length, "string_fixed expects written string length (in bytes) to match the allocated length.") end

			write()
		end,
	}) :: types.DatatypeInterface<string>
end
