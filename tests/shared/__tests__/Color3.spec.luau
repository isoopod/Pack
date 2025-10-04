local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

describe("Color3", function()
	local schema = Pack:Define(Pack.Color3)
	-- Standard color cases
	it("Should handle all 24-bit colors correctly", function()
		for r = 0, 255 do
			for g = 0, 255 do
				for b = 0, 255 do
					local expected = Color3.fromRGB(r, g, b)

					local packet = schema:Write(expected)
					local actual = schema:Read(packet)

					expect(actual).toBe(expected)
				end
			end
		end
	end)

	it("Should be 3 bytes", function()
		local packet = schema:Write(Color3.new())
		expect(buffer.len(packet)).toBe(3)
	end)

	it("Should trim values > 255", function()
		local expected = Color3.fromRGB(500, 500, 500)

		local packet = schema:Write(expected)
		local actual = schema:Read(packet)

		expect(actual).never.toBe(expected)
	end)
end)

describe("Color3float32", function()
	local schema = Pack:Define(Pack.Color3float32)
	-- Standard color cases
	it("Should handle all 24-bit colors correctly", function()
		for r = 0, 255 do
			for g = 0, 255 do
				for b = 0, 255 do
					local expected = Color3.fromRGB(r, g, b)

					local packet = schema:Write(expected)
					local actual = schema:Read(packet)

					expect(actual).toBe(expected)
				end
			end
		end
	end)

	it("Should be 12 bytes", function()
		local packet = schema:Write(Color3.new())
		expect(buffer.len(packet)).toBe(12)
	end)

	it("Should handle values > 255", function()
		local expected = Color3.fromRGB(500, 500, 500)

		local packet = schema:Write(expected)
		local actual = schema:Read(packet)

		expect(actual).toBe(expected)
	end)
end)
