--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "s16",
	Read = function(reader: types.ReaderData): string
		local len = Reader.u16(reader)
		return Reader.string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = Writer.string(writer, value)

		Writer.alloc(writer, 2)
		Writer.u16(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
