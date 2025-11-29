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
		-- Values below 0 should wrap to high end
		local negative = -0.5
		local packet = schema:Write(negative)
		local actual = schema:Read(packet)
		-- -0.5 wraps to approximately 0.5 due to unsigned integer overflow
		expect(actual).toBeCloseTo(0.5, 4)

		-- Values above 1 should wrap to low end
		local above_one = 1.5
		packet = schema:Write(above_one)
		actual = schema:Read(packet)
		-- 1.5 wraps to approximately 0.5
		expect(actual).toBeCloseTo(0.5, 4)

		-- Test that wrapping is consistent
		expect(schema:Read(schema:Write(-0.25))).toBeCloseTo(0.75, 4)
		expect(schema:Read(schema:Write(2.0))).toBeCloseTo(0.0, 4)
	end)
end)
