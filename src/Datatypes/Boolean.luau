--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "bool",
	Read = function(reader: types.ReaderData): boolean
		return Reader.u8(reader) == 1
	end,
	Write = function(writer: types.WriterData, value: boolean)
		Writer.alloc(writer, 1)
		Writer.u8(writer, value and 1 or 0)
	end,
}) :: types.DatatypeInterface<boolean>

return datatype
