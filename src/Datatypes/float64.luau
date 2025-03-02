--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "f64",
	Read = function(Reader: types.Reader): number
		return Reader:f64()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(8)
		Writer:f64(value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
