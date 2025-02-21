--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "s16",
	Read = function(Reader: types.Reader): string
		local len = Reader:u16()
		return Reader:string(len)
	end,
	Write = function(Writer: types.Writer, value: string)
		local len, write = Writer:string(value)

		Writer:alloc(2)
		Writer:u16(len)

		write()
	end,
}) :: types.DatatypeInterface<string>

return datatype
