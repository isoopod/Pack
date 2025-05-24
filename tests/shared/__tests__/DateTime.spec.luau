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
		local negative = DateTime.fromUnixTimestampMillis(-17987443200000) -- Min timestamp millis
		local buffer = schema:Write(negative)
		local result = schema:Read(buffer)
		expect(result.UnixTimestampMillis).toBe(-17987443200000)
	end)

	it("should correctly handle a large timestamp within f64 precision", function()
		local maxExact = DateTime.fromUnixTimestampMillis(253402300799999) -- Max timestamp millis
		local buffer = schema:Write(maxExact)
		local result = schema:Read(buffer)
		expect(result.UnixTimestampMillis).toBe(253402300799999)
	end)
end)
