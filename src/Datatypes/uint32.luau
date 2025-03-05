--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "u32",
	Read = function(reader: types.ReaderData): number
		return Reader.u32(reader)
	end,
	Write = function(writer: types.WriterData, value: number)
		Writer.alloc(writer, 4)
		Writer.u32(writer, value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
