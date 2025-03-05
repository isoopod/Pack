--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "i8",
	Read = function(reader: types.ReaderData): number
		return Reader.i8(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		Writer.alloc(writer, 1)
		Writer.i8(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
