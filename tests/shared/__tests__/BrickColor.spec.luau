local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local schemaModule = Pack.BrickColor

describe("BrickColor", function()
	-- Standard color cases
	it("should serialize/deserialize common colors correctly", function()
		local schema = Pack:Define(schemaModule)
		local testColors = {
			BrickColor.new("Bright red"),
			BrickColor.new("Bright blue"),
			BrickColor.new("Medium green"),
			BrickColor.new("White"),
			BrickColor.new("Black"),
		}

		for _, color in testColors do
			local b = schema:Write(color)
			local result = schema:Read(b)

			expect(result).toEqual(color)
			expect(buffer.len(b)).toEqual(2) -- Must always use 2 bytes
		end
	end)

	-- Edge cases
	it("should handle first and last palette colors", function()
		local schema = Pack:Define(schemaModule)

		-- First color in default palette (1 - White)
		local firstColor = BrickColor.new(1)
		local firstBuffer = schema:Write(firstColor)
		expect(schema:Read(firstBuffer)).toEqual(firstColor)

		-- Last color in default palette (192 - Sand red)
		local lastColor = BrickColor.new(192)
		local lastBuffer = schema:Write(lastColor)
		expect(schema:Read(lastBuffer)).toEqual(lastColor)
	end)

	-- Round-trip consistency
	it("should maintain consistency through multiple serializations", function()
		local schema = Pack:Define(schemaModule)
		local color = BrickColor.new("Lime green")

		-- First serialization
		local buffer1 = schema:Write(color)
		local result1 = schema:Read(buffer1)

		-- Second serialization
		local buffer2 = schema:Write(result1)
		local result2 = schema:Read(buffer2)

		expect(result1).toEqual(color)
		expect(result2).toEqual(color)
	end)
end)
