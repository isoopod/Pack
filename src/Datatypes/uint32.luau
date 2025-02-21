--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "u32",
	Read = function(Reader: types.Reader): number
		return Reader:u32()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(4)
		Writer:u32(value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
