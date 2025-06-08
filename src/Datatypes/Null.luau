--!strict
--!native
--!optimize 2

local types = require("../types")

local datatype: types.DatatypeInterface<nil> = table.freeze({
	Eval = "nil",
	Read = function(): nil
		return nil
	end,
	Write = function() end,
}) :: any

return datatype
