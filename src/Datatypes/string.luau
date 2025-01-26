--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<string> = {
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
}

-- TODO: Add flags for max string size, a u16 will not be enough for all applications
return datatype
