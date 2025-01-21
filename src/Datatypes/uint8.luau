--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<number> = {
	Read = function(Reader: types.Reader): number
		return Reader:u8()
	end,
	Write = function(Writer: types.Writer, value: number)
		Writer:alloc(1)
		Writer:u8(value)
	end,
}

return datatype
