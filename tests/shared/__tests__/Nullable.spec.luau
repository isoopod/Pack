local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local schema = Pack:Define(Pack.Nullable(Pack.String16))

describe("Nullable", function()
	it("should correctly encode and decode a non-nil string", function()
		local input = "Hello World!"
		local encoded = schema:Write(input)
		local decoded = schema:Read(encoded)

		expect(decoded).toEqual(input)
	end)

	it("should correctly encode and decode nil", function()
		local input = nil
		local encoded = schema:Write(input)
		local decoded = schema:Read(encoded)

		expect(decoded).toBeNil()
	end)

	it("should encode different values with and without nil differently", function()
		local input1 = nil
		local input2 = "non-nil"

		local encoded1 = schema:Write(input1)
		local encoded2 = schema:Write(input2)

		expect(buffer.tostring(encoded1)).never.toEqual(buffer.tostring(encoded2))
	end)

	it("should only add 1 byte for 8 nullables", function()
		-- Dictionaries should not add any overhead to the packet
		local schema2 = Pack:Define(Pack.Dictionary({
			[1] = Pack.Nullable(Pack.Boolean),
			[2] = Pack.Nullable(Pack.Boolean),
			[3] = Pack.Nullable(Pack.Boolean),
			[4] = Pack.Nullable(Pack.Boolean),
			[5] = Pack.Nullable(Pack.Boolean),
			[6] = Pack.Nullable(Pack.Boolean),
			[7] = Pack.Nullable(Pack.Boolean),
			[8] = Pack.Nullable(Pack.Boolean),
		}))

		local encoded1 = schema2:Write({ true, true, true, true, true, true, true, true })
		local encoded2 = schema2:Write({})

		expect(buffer.len(encoded1)).toEqual(9)
		expect(buffer.len(encoded2)).toEqual(1)
	end)
end)
