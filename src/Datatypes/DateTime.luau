--!strict
--!native
--!optimize 2

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "DateTime",
	Read = function(reader: types.ReaderData): DateTime
		return DateTime.fromUnixTimestampMillis(Reader.f64(reader))
	end,
	Write = function(writer: types.WriterData, value: DateTime)
		Writer.alloc(writer, 8)
		Writer.f64(writer, value.UnixTimestampMillis)
	end,
}) :: types.DatatypeInterface<DateTime>

return datatype
