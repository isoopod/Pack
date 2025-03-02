--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "u8",
	Read = function(Reader: types.Reader): number
		return Reader:u8()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(1)
		Writer:u8(value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
