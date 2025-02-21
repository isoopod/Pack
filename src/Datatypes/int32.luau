--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "i32",
	Read = function(Reader: types.Reader): number
		return Reader:i32()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(4)
		Writer:i32(value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
