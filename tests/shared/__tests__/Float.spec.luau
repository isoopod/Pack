local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local floatCases = {
	0,
	1.5,
	-2.75,
	12345.678,
	-0.0001,
}

local specialCases = {
	NaN = 0 / 0,
	Infinity = math.huge,
	NegInfinity = -math.huge,
}

local percision = {
	Float16 = -1,
	Float24 = 0,
	Float32 = 3,
	Float64 = 5,
}

describe("Floats", function()
	for _, bitType in { "Float16", "Float24", "Float32", "Float64" } do
		describe(bitType, function()
			local schema = Pack:Define(Pack[bitType])
			it("should round-trip typical values", function()
				for _, v in floatCases do
					local buf = schema:Write(v)
					local res = schema:Read(buf)
					expect(res).toBeCloseTo(v, percision[bitType])
				end
			end)

			it("should handle NaN and infinities", function()
				-- NaN
				local bufNaN = schema:Write(specialCases.NaN)
				local resNaN = schema:Read(bufNaN)
				expect(resNaN).toBeNan()

				-- Infinity
				local bufInf = schema:Write(specialCases.Infinity)
				local resInf = schema:Read(bufInf)
				expect(resInf).toBe(math.huge)

				-- Negative Infinity
				local bufNegInf = schema:Write(specialCases.NegInfinity)
				local resNegInf = schema:Read(bufNegInf)
				expect(resNegInf).toBe(-math.huge)
			end)
		end)
	end
end)
