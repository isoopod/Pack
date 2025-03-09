--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "s32",
	Read = function(reader: types.ReaderData): string
		local len = Reader.nBitUint(reader, 24, 0)
		return Reader.string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len, write = Writer.string(writer, value)

		Writer.alloc(writer, 3)
		Writer.nBitUint(writer, len, 24, 0)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
