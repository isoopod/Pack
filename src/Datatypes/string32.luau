--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<string> = {
	Read = function(Reader: types.Reader): string
		local len = Reader:u32()
		return Reader:string(len)
	end,
	Write = function(Writer: types.Writer, value: string)
		local len, write = Writer:string(value)

		Writer:alloc(4)
		Writer:u32(len)

		write()
	end,
}

return datatype
