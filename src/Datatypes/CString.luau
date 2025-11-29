--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u8 = Reader.u8
local read_string = Reader.string
local read_moveCursor = Reader.moveCursor

local write_string = Writer.string
local write_alloc = Writer.alloc

local datatype = table.freeze({
	Eval = "sZ",
	Len = 1,
	Read = function(reader: types.ReaderData): string
		local len = 0
		while true do
			local byte = read_u8(reader)
			if byte == 0 then break end
			len += 1
		end
		read_moveCursor(reader, -len - 1)
		return read_string(reader, len)
	end,
	Write = function(writer: types.WriterData, value: string)
		local len = #value

		write_alloc(writer, len + 1)

		write_string(writer, value .. "\0", len)
	end,
}) :: types.DatatypeInterface<string>

return datatype
