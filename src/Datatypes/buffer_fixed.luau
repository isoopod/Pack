--!strict
--!native
--!optimize 2
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local types = require(script.Parent.Parent.Types)

local PACK_CONFIG = (SharedTableRegistry:GetSharedTable("PACK_CONFIG")) :: SharedTable
local DEBUG = PACK_CONFIG.__DEBUG__ == true

return function(length: number): types.DatatypeInterface<buffer>
	return {
		Read = function(Reader: types.Reader): buffer
			return buffer.fromstring(Reader:string(length))
		end,
		Write = function(Writer: types.Writer, value: buffer)
			local len, write = Writer:string(buffer.tostring(value))
			if DEBUG then assert(len == length, "buffer_fixed expects written buffer length (in bytes) to match the allocated length.") end

			write()
		end,
	}
end
