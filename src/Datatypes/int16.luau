--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "i16",
	Read = function(Reader: types.Reader): number
		return Reader:i16()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(2)
		Writer:i16(value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
