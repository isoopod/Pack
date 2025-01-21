--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<buffer> = {
	Read = function(Reader: types.Reader): buffer
		local len = Reader:u16()
		return buffer.fromstring(Reader:string(len))
	end,
	Write = function(Writer: types.Writer, value: buffer)
		local len, write = Writer:string(buffer.tostring(value))

		Writer:alloc(2)
		Writer:u16(len)

		write()
	end,
}

-- TODO: Add flags for max buffer size, a u16 will not be enough for all applications
return datatype
