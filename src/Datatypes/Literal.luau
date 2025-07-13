--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

return function(value: any): types.DatatypeInterface<any>
	return table.freeze({
		Eval = "lit",
		val = value,
		Read = function(): buffer
			return value
		end,
		Write = function() end,
	}) :: types.DatatypeInterface<buffer>
end
