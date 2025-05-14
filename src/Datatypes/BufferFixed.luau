--!strict
--!native
--!optimize 2
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local PACK_CONFIG = (SharedTableRegistry:GetSharedTable("PACK_CONFIG"))
local DEBUG = PACK_CONFIG.__DEBUG__ == true

return function(length: number): types.DatatypeInterface<buffer>
	return table.freeze({
		Eval = "buffer",
		len = length,
		Read = function(reader: types.ReaderData): buffer
			return buffer.fromstring(Reader.string(reader, length))
		end,
		Write = function(writer: types.WriterData, value: buffer)
			local len, write = Writer.string(writer, buffer.tostring(value))
			if DEBUG then assert(len == length, "BufferFixed expects written buffer length (in bytes) to match the allocated length.") end

			write()
		end,
	}) :: types.DatatypeInterface<buffer>
end
