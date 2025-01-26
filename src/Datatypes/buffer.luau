--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

return function(flag: "8bit" | "16bit" | "32bit" | "fixed", length: number?): types.DatatypeInterface<buffer>
	flag = flag or "16bit" :: any
	if flag == "fixed" and not length then error("len expected when using fixed flag on datatype string.") end

	if flag == "fixed" then
		return {
			Read = function(Reader: types.Reader): buffer
				return buffer.fromstring(Reader:string(length))
			end,
			Write = function(Writer: types.Writer, value: buffer)
				local len, write = Writer:string(buffer.tostring(value))
				assert(len == length, "When using fixed length buffers, the written length must be equal to the allocated length.")
				write()
			end,
		}
	end

	local blen = (flag == "8bit" and 1) or (flag == "16bit" and 2) or 4
	local interface = (flag == "8bit" and "u8") or (flag == "16bit" and "u16") or "u32"

	return {
		Read = function(Reader: types.Reader): buffer
			local len = Reader[interface](Reader)
			return buffer.fromstring(Reader:string(len))
		end,
		Write = function(Writer: types.Writer, value: buffer)
			local len, write = Writer:string(buffer.tostring(value))

			Writer:alloc(blen)
			Writer[interface](Writer, len)

			write()
		end,
	}
end
