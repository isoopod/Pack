local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

describe("EnumItem", function()
	it("should correctly write and read items from Enum.KeyCode", function()
		local schema = Pack:Define(Pack.EnumItem(Enum.KeyCode))
		local originals = { Enum.KeyCode.A, Enum.KeyCode.Z, Enum.KeyCode.Space }
		for _, original in originals do
			local buffer = schema:Write(original)
			local result = schema:Read(buffer)
			expect(result).toBe(original)
		end
	end)

	it("should correctly write and read items from Enum.Material", function()
		local schema = Pack:Define(Pack.EnumItem(Enum.Material))
		local originals = { Enum.Material.Plastic, Enum.Material.Wood, Enum.Material.DiamondPlate }
		for _, original in originals do
			local buffer = schema:Write(original)
			local result = schema:Read(buffer)
			expect(result).toBe(original)
		end
	end)

	it("should handle enums requiring u16 (value > 255)", function()
		local schema = Pack:Define(Pack.EnumItem(Enum.KeyCode))
		local highValueItem = Enum.KeyCode.F13
		local buffer = schema:Write(highValueItem)
		local result = schema:Read(buffer)
		expect(result).toBe(highValueItem)
	end)
end)
