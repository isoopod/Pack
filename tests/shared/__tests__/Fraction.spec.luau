local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

-- These should all be exactly the same
local exactCases = {
	0,
	2 ^ -16,
	0.125,
	0.1,
	0.25,
	0.5,
	0.75,
	0.875,
	1 - 2 ^ -16,
	1,
}

-- These cases wont be exact, but should be within 2^-16 of what is expected
local inexactCases = {
	0.1,
	1 / 3,
}

describe("Fraction", function()
	local schema = Pack:Define(Pack.Frac)

	it("should round-trip multiples of 2^-16 exactly", function()
		for _, expected in exactCases do
			local packet = schema:Write(expected)
			local actual = schema:Read(packet)
			expect(actual).toBe(expected)
		end
	end)

	it("should round-trip other values within precision", function()
		for _, expected in inexactCases do
			local packet = schema:Write(expected)
			local actual = schema:Read(packet)
			expect(math.abs(actual - expected)).toBeLessThanOrEqual(2 ^ -16)
		end
	end)

	it("should wrap on out-of-range values", function()
		local expected = -2 ^ -16
		local packet = schema:Write(expected)
		local actual = schema:Read(packet)
		expect(actual).never.toBe(expected)
	end)
end)
