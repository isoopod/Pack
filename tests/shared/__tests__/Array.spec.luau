local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

describe("Array", function()
	local schema = Pack:Define(Pack.Array(Pack.UInt8))

	it("writes the correct buffer length", function()
		local values = {
			{},
			{ 1 },
			{ 1, 2, 3, 4, 5 },
			table.create(255, 42),
		}

		for _, array in values do
			local packet = schema:Write(array)
			expect(buffer.len(packet)).toBe(2 + #array) -- 2 bytes for length, 1 byte per UInt8
		end
	end)

	it("round-trips UInt8 arrays", function()
		local testCases = {
			{},
			{ 0 },
			{ 255 },
			{ 1, 2, 3, 4, 5 },
			{ 255, 128, 64, 32, 0 },
		}

		for _, original in testCases do
			local packet = schema:Write(original)
			local result = schema:Read(packet)
			expect(result).toEqual(original)
		end
	end)

	it("supports variable length datatypes", function()
		local schema2 = Pack:Define(Pack.Array(Pack.String8))

		local testCases = {
			{ "Hello", "World!!!" },
			{ "Hello" },
			{ "a", "b", "c", "d", "e" },
			{ string.rep("x", 255), "Hello World", "asdaweg", "ogjeiusehr" },
		}

		for _, original in testCases do
			local packet = schema2:Write(original)
			local result = schema2:Read(packet)
			expect(result).toEqual(original)
		end
	end)
end)
