local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

describe("Map", function()
	it("round-trips String8->UInt8", function()
		local schema = Pack:Define(Pack.Map(Pack.String8, Pack.UInt8))

		local testCases = {
			{},
			{ a = 1, b = 2, c = 3, d = 4, e = 5 },
			{ foo = 255, bar = 128, baz = 64, qux = 32, quux = 0 },
			{ key = 42 },
			{ longstringkey = 100, anotherlongstringkey = 200 },
			{ [""] = 0, [" "] = 1, ["  "] = 2 },
			{ ["special!@#$%^&*()_+"] = 123, ["😀"] = 0 },
		}

		for _, original in testCases do
			local packet = schema:Write(original)
			local result = schema:Read(packet)
			expect(result).toEqual(original)
		end
	end)

	it("should support nested maps", function()
		local schema = Pack:Define(Pack.Map(Pack.String8, Pack.Map(Pack.String8, Pack.UInt8)))

		local testCases = {
			{},
			{ a = { x = 1, y = 2 }, b = { z = 3 } },
			{ foo = { bar = 255, baz = 128 }, qux = { quux = 64, corge = 32 } },
			{ key1 = { subkey1 = 42 }, key2 = { subkey2 = 100, subkey3 = 200 } },
		}

		for _, original in testCases do
			local packet = schema:Write(original)
			local result = schema:Read(packet)
			expect(result).toEqual(original)
		end
	end)
end)
