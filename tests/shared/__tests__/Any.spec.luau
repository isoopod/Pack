local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local anySchema = Pack:Define(Pack.Any)

describe("Any", function()
	it("round trips a number correctly", function()
		local value = 123.456
		local encoded = anySchema:Write(value)
		local decoded = anySchema:Read(encoded)
		expect(decoded).toBeCloseTo(value, 4)
	end)

	it("round trips a negative integer correctly", function()
		local value = -42
		local encoded = anySchema:Write(value)
		local decoded = anySchema:Read(encoded)
		expect(decoded).toEqual(value)
	end)

	it("round trips a boolean correctly", function()
		for _, value in { true, false } do
			local encoded = anySchema:Write(value)
			local decoded = anySchema:Read(encoded)
			expect(decoded).toEqual(value)
		end
	end)

	it("round trips a string correctly", function()
		local value = "test-string"
		local encoded = anySchema:Write(value)
		local decoded = anySchema:Read(encoded)
		expect(decoded).toEqual(value)
	end)

	it("round trips nil correctly", function()
		local value = nil
		local encoded = anySchema:Write(value)
		local decoded = anySchema:Read(encoded)
		expect(decoded).toBeNil()
	end)

	it("round trips an array table correctly", function()
		local value = { 10, 20, 30 }
		local encoded = anySchema:Write(value)
		local decoded = anySchema:Read(encoded)
		expect(decoded).toEqual(value)
	end)

	it("round trips a map table correctly", function()
		local value = { alpha = 1, beta = 2, gamma = 3 }
		local encoded = anySchema:Write(value)
		local decoded = anySchema:Read(encoded)
		expect(decoded).toEqual(value)
	end)

	it("round trips nested tables correctly", function()
		local value = {
			list = { 1, 2, 3 },
			dict = { x = "X", y = "Y" },
		}
		local encoded = anySchema:Write(value)
		local decoded = anySchema:Read(encoded)
		expect(decoded).toEqual(value)
	end)

	it("throws when given an unsupported value type", function()
		expect(function()
			-- Functions are not supported by Any (or Pack in general)
			anySchema:Write(function() end)
		end).toThrow()
	end)
end)
