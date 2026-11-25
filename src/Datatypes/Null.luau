--!native
--!optimize 2

const types = require(script.Parent.Parent.types)

const datatype: types.DatatypeInterface<nil> = table.freeze({
	Eval = "nil",
	Read = function(): nil
		return nil
	end,
	Write = function() end,
}) :: any

return datatype
