local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local function testStringType(name, datatype, len: number)
	local schema = Pack:Define(datatype)

	describe(name, function()
		it("should round-trip string data", function()
			local original = "Hello, world!"
			local buf = schema:Write(original)
			local result = schema:Read(buf)
			expect(result).toBe(original)
		end)

		it("should round-trip empty string", function()
			local original = ""
			local buf = schema:Write(original)
			local result = schema:Read(buf)
			expect(result).toBe(original)
		end)

		it("should round-trip maximum sized string", function()
			local expected = string.rep("x", math.min(2 ^ len - 1, 2 ^ 30 - 4))
			local buf = schema:Write(expected)
			local actual = schema:Read(buf)
			expect(actual).toBe(expected)
		end)
	end)
end

testStringType("String8", Pack.String8, 8)
testStringType("String16", Pack.String16, 16)
testStringType("String24", Pack.String24, 24)
testStringType("String32", Pack.String32, 32)

-- Test for StringFixed

describe("StringFixed", function()
	it("should round-trip exact length string", function()
		local fixedLen = 5
		local datatype = Pack.StringFixed(fixedLen)
		local schema = Pack:Define(datatype)

		local original = "Hello"
		local buf = schema:Write(original)
		local result = schema:Read(buf)

		expect(result).toBe(original)
	end)

	it.skip("should error on string length mismatch", function()
		local fixedLen = 5
		local datatype = Pack.StringFixed(fixedLen)
		local schema = Pack:Define(datatype)

		-- This test assumes DEBUG = true in PACK_CONFIG
		expect(function()
			schema:Write("Hi")
		end).toThrow()
	end)
end)
