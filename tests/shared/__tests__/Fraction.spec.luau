local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

-- These should all be exactly the same
local cases = {
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
	0.1,
	1 / 3,
}

describe("Fraction", function()
	local schema = Pack:Define(Pack.Frac)

	it("should round-trip values inside range within precision", function()
		for _, expected in cases do
			local packet = schema:Write(expected)
			local actual = schema:Read(packet)
			expect(math.abs(actual - expected)).toBeLessThanOrEqual(2 ^ -16)
		end
	end)

	it("should wrap on out-of-range values", function()
		local expected = -2 ^ -16
		local packet = schema:Write(expected)
		local actual = schema:Read(packet)
		expect(math.abs(actual - expected)).toBeLessThanOrEqual(1)
	end)
end)
