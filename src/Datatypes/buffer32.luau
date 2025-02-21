--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype = table.freeze({
	Eval = "buffer32",
	Read = function(Reader: types.Reader): buffer
		local len = Reader:u32()
		return buffer.fromstring(Reader:string(len))
	end,
	Write = function(Writer: types.Writer, value: buffer)
		local len, write = Writer:string(buffer.tostring(value))

		Writer:alloc(4)
		Writer:u32(len)

		write()
	end,
}) :: types.DatatypeInterface<buffer>

return datatype
