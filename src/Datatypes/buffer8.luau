--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<buffer> = {
	Read = function(Reader: types.Reader): buffer
		local len = Reader:u8()
		return buffer.fromstring(Reader:string(len))
	end,
	Write = function(Writer: types.Writer, value: buffer)
		local len, write = Writer:string(buffer.tostring(value))

		Writer:alloc(1)
		Writer:u8(len)

		write()
	end,
}

return datatype
