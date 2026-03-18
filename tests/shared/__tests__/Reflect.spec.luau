local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local schema = Pack:Define(Pack.Struct({
	Simple = Pack.Int16,
	Nested = Pack.Struct({
		Inner = Pack.Boolean,
	}),
	Sparse = Pack.SparseDictionary({
		SparseKey = Pack.Boolean,
	}),
	Nullable = Pack.Nullable(Pack.String16),
}))

describe("Reflect", function()
	it("Should support non-nested values", function()
		local test = assert(Pack:Reflect(schema, "Simple"))
		local result = test:Read(test:Write(72))
		expect(result).toEqual(72)
	end)
	it("Should support nested values", function()
		local test = assert(Pack:Reflect(schema, "Nested/Inner"))
		local result = test:Read(test:Write(true))
		expect(result).toBeTruthy()

		local test2 = assert(Pack:Reflect(schema, "Nested"))
		local result2 = test2:Read(test2:Write({ Inner = true }))
		expect(result2).toEqual({ Inner = true })
	end)
	it("Should support sparse nested values", function()
		local test = assert(Pack:Reflect(schema, "Sparse/SparseKey"))
		local result = test:Read(test:Write(true))
		expect(result).toBeTruthy()
	end)
	it("Should treat other container types as primitive", function()
		-- In other words Nullable(something) should reflect to Nullable(something) not just something
		-- Same deal with Union etc...
		local test = assert(Pack:Reflect(schema, "Nullable"))
		local result = test:Read(test:Write(nil))
		expect(result).toBeNil()
	end)
end)
