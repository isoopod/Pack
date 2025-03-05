--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "s32",
	Read = function(reader: types.ReaderData): string
		local len = Reader.u32(reader)
		return Reader.string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = Writer.string(writer, value)

		Writer.alloc(writer, 4)
		Writer.u32(writer, len)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
