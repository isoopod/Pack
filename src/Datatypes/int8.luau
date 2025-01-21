--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:i8()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(1)
		Writer:i8(value)
	end,
}

return datatype
