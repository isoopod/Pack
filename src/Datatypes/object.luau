--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

-- Allows marshalling objects given the class metatable and data structure
-- Note that this creates a duplicate of the object, not a reference to the original.
-- classData is a Dictionary describing the data the class stores
-- Note that this might not work well for all metatable configurations, but should work well enough for common practices.
return function(metatable: { [any]: any }, classData: types.DatatypeInterface<any>): types.DatatypeInterface<any>
	return table.freeze({
		Eval = "object",
		Read = function(Reader: types.Reader): any
			return setmetatable(classData.Read(Reader), metatable)
		end,
		Write = function(Writer: types.Writer, value: any)
			assert(type(value) == "table", "An Object must be a table")
			classData.Write(Writer, value)
		end,
	}) :: types.DatatypeInterface<any>
end
