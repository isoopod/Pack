--!native
--!optimize 2

local types = require(script.Parent.Parent.types)

-- Wrap a custom read and write function to create your own datatype for use in a schema.
-- If you have a custom datatype that needs to be used in many schemas, you should create a datatype module for that.
-- This is good for custom datatypes that make extensive use of bit packing.
-- You cannot use these inside unions.

return function<T>(read: (types.ReaderData) -> T, write: (writer: types.WriterData, value: T) -> ()): types.DatatypeInterface<T>
	return table.freeze({
		Read = function(reader: types.ReaderData): T?
			return read(reader)
		end,
		Write = function(writer: types.WriterData, value: T)
			write(writer, value)
		end,
	}) :: types.DatatypeInterface<T>
end
