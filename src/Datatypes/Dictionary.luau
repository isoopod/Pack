--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

--[=[
        @function Dictionary
        @within Datatypes
        @param valueType: any
        A Pack 'Dictionary' is a table with predefined string keys. This is a very efficient way of storing complex data in a convenient way.  
		Dictionaries are nestable. When writing a dictionary, all keys must be provided. You can use Pack.Nullable for to create optional values
		in a Dictionary.
		

		```
		local packet = Pack.definePacket(Pack.Dictionary({
			Number = Pack.Int,
			["Lots of numbers"] = Pack.Array(Pack.Int),
			NestedDictionary = Pack.Dictionary({
				Contents = Pack.String,
			})
		}))
		
		-- You then write it as a dictionary
		local payload = packet:Write({
			Number = 6,
			["Lots of numbers"] = {1, 2, 3, 4 ,5},
			NestedDictionary = {
				Contents = "Hello World!",
			},
		})

		local uncompressed = packet:Read(payload)
		print(uncompressed) --[[ => {
										Number = 6,
										["Lots of numbers"] = {1, 2, 3, 4 ,5},
										NestedDictionary = {
											Contents = "Hello World!",
										},
									} 
								]]
		```

		Dictionaries are equivalent to ByteNet structs.
]=]

return function(format: { [string]: types.DatatypeInterface<any> }): types.DatatypeInterface<{}>
	-- In order to make it so we can read and write a dictionary in the same order, we will take all the provided elements, and assign them with an index alphanumerically
	local len = 0
	for _ in format do
		len += 1
	end

	local order = table.create(len) :: { string }

	for k in format do
		table.insert(order, k)
	end

	table.sort(order)

	return {
		Read = function(Reader: types.Reader)
			local result = {}

			for i = 1, len do
				local key = order[i]
				result[key] = format[key].Read(Reader)
			end

			return result
		end,
		Write = function(Writer: types.Writer, value: { [string]: types.DatatypeInterface<any> })
			for i = 1, len do
				local key = order[i]
				format[key].Write(Writer, value[key])
			end
		end,
	} :: any
end
