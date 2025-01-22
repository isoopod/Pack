--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

-- Wrap a custom read and write function to create your own datatype for use in a schema.
-- If you have a custom datatype that needs to be used in many schemas, you should create a datatype module for that.
-- This is good for custom datatypes that make extensive use of bit packing

return function<T>(read: (types.Reader) -> T, write: (writer: types.Writer, value: T) -> ()): types.DatatypeInterface<T>
	return {
		Read = function(Reader: types.Reader): T?
			return read(Reader)
		end,
		Write = function(Writer: types.Writer, value: T)
			write(Writer, value)
		end,
	}
end
