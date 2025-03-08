--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "s8",
	Read = function(reader: types.ReaderData): string
		local len = Reader.u8(reader)
		return Reader.string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = Writer.string(writer, value)

		Writer.alloc(writer, 1)
		Writer.u8(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
