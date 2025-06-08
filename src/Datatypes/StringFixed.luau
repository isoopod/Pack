--!strict
--!native
--!optimize 2
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_string = Reader.string

local write_string = Writer.string

local PACK_CONFIG = (SharedTableRegistry:GetSharedTable("PACK_CONFIG"))
local DEBUG = PACK_CONFIG.__DEBUG__ == true

return function(length: number): types.DatatypeInterface<string>
	return table.freeze({
		Eval = "string",
		len = length,
		Read = function(reader: types.ReaderData): string
			return read_string(reader, length)
		end,
		Write = function(writer: types.WriterData, value: string)
			local len, write = write_string(writer, value)
			if DEBUG then assert(len == length, "string_fixed expects written string length (in bytes) to match the allocated length.") end

			write()
		end,
	}) :: types.DatatypeInterface<string>
end
