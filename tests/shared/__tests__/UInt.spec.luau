local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local function max(bits: number): number
	return (2 ^ bits) - 1
end

local intCases = {
	UInt8 = { 0, 1, max(8) },
	UInt16 = { 0, 1, max(16) },
	UInt32 = { 0, 1, max(32) },
	UInt64 = { 0, 1, max(32), max(53), max(53) + 1, max(64) - 2000 }, -- The extreme is not exact but the implementation is not exact past 2^53
}

describe("UInts", function()
	for typeName, cases in intCases do
		describe(typeName, function()
			local schema = Pack:Define(Pack[typeName])

			it("should round-trip values", function()
				for _, expected in cases do
					local packet = schema:Write(expected)
					local actual = schema:Read(packet)
					expect(actual).toBe(expected)
				end
			end)

			-- Loss of precision means this test will always fail
			if typeName ~= "UInt64" then
				it("should wrap on out-of-range values", function()
					local expected = cases[#cases] + 1
					local packet = schema:Write(expected)
					local actual = schema:Read(packet)
					expect(actual).never.toBe(expected)
				end)
			end
		end)
	end
end)
