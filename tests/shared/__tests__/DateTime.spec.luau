local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local schema = Pack:Define(Pack.DateTime)

describe("DateTime", function()
	it("should correctly write and read the current DateTime", function()
		local original = DateTime.now()
		local buffer = schema:Write(original)
		local result = schema:Read(buffer)
		expect(result.UnixTimestampMillis).toBe(original.UnixTimestampMillis)
	end)

	it("should correctly handle the Unix epoch (0 ms)", function()
		local epoch = DateTime.fromUnixTimestampMillis(0)
		local buffer = schema:Write(epoch)
		local result = schema:Read(buffer)
		expect(result.UnixTimestampMillis).toBe(0)
	end)

	it("should correctly handle a negative timestamp (pre-1970)", function()
		local negative = DateTime.fromUnixTimestampMillis(-123456789)
		local buffer = schema:Write(negative)
		local result = schema:Read(buffer)
		expect(result.UnixTimestampMillis).toBe(-123456789)
	end)

	it("should correctly handle a large timestamp within f64 precision", function()
		-- 2^53 is the max integer exactly representable by f64
		local maxExact = DateTime.fromUnixTimestampMillis(2 ^ 53)
		local buffer = schema:Write(maxExact)
		local result = schema:Read(buffer)
		expect(result.UnixTimestampMillis).toBe(2 ^ 53)
	end)
end)
