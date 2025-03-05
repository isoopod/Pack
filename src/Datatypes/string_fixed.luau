--!strict
--!native
--!optimize 2
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local PACK_CONFIG = (SharedTableRegistry:GetSharedTable("PACK_CONFIG")) :: SharedTable
local DEBUG = PACK_CONFIG.__DEBUG__ == true

return function(length: number): types.DatatypeInterface<string>
	return table.freeze({
		Eval = "string",
		Read = function(reader: types.ReaderData): string
			return Reader.string(reader, length)
		end,
		Write = function(writer: types.WriterData, value: string)
			local len, write = Writer.string(writer, value)
			if DEBUG then assert(len == length, "string_fixed expects written string length (in bytes) to match the allocated length.") end

			write()
		end,
	}) :: types.DatatypeInterface<string>
end
