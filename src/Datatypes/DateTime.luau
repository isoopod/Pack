--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

local datatype = table.freeze({
	Eval = "DateTime",
	Read = function(Reader: types.Reader): DateTime
		return DateTime.fromUnixTimestampMillis(Reader:f64())
	end,
	Write = function(Writer: types.Writer, value: DateTime)
		Writer:alloc(8)
		Writer:f64(value.UnixTimestampMillis)
	end,
}) :: types.DatatypeInterface<DateTime>

return datatype
