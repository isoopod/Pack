local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local intCases = {
	Int8 = { 0, 1, -1, 127, -128 },
	Int16 = { 0, 1, -1, 32767, -32768 },
	Int32 = { 0, 1, -1, 2147483647, -2147483648 },
	Int64 = { 0, 1, -1, 2 ^ 63 - 4000, -2 ^ 63 + 2000 }, -- The extremes are not exact because of floating point precision, but the implementation is not exact either.
}

describe("Ints", function()
	for typeName, cases in intCases do
		describe(typeName, function()
			local schema = Pack:Define(Pack[typeName])

			it("should round-trip values", function()
				for _, v in cases do
					local buf = schema:Write(v)
					local res = schema:Read(buf)
					expect(res).toBe(v)
				end
			end)

			-- Loss of precision means this test will always fail
			if typeName ~= "Int64" then
				it("should wrap on out-of-range values", function()
					local outOfRangePos = cases[#cases] - 1
					local buf1 = schema:Write(outOfRangePos)
					local res1 = schema:Read(buf1)
					expect(res1).never.toBe(outOfRangePos)

					local outOfRangeNeg = cases[#cases - 1] + 1
					local buf2 = schema:Write(outOfRangeNeg)
					local res2 = schema:Read(buf2)
					expect(res2).never.toBe(outOfRangeNeg)
				end)
			end
		end)
	end
end)
