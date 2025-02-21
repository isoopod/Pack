--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "f32",
	Read = function(Reader: types.Reader): number
		return Reader:f32()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(4)
		Writer:f32(value)
	end,
}) :: types.DatatypeInterface<number>

return datatype
