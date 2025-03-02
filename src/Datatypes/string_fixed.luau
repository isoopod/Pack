--!strict
--!native
--!optimize 2
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local types = require(script.Parent.Parent.types)

local PACK_CONFIG = (SharedTableRegistry:GetSharedTable("PACK_CONFIG")) :: SharedTable
local DEBUG = PACK_CONFIG.__DEBUG__ == true

return function(length: number): types.DatatypeInterface<string>
	return table.freeze({
		Eval = "string",
		Read = function(Reader: types.Reader): string
			return Reader:string(length)
		end,
		Write = function(Writer: types.Writer, value: string)
			local len, write = Writer:string(value)
			if DEBUG then assert(len == length, "string_fixed expects written string length (in bytes) to match the allocated length.") end

			write()
		end,
	}) :: types.DatatypeInterface<string>
end
