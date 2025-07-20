local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local unionSchema = Pack:Define(Pack.Union(
	-- Numeric types
	Pack.UInt8,
	Pack.Int16,
	-- Boolean
	Pack.Boolean,
	-- Strings
	Pack.String8,
	-- BitField of length 3
	Pack.BitField(3),
	-- Dictionary with two keys
	Pack.Dictionary({ A = Pack.UInt8, B = Pack.String8 }),
	-- Array of Int16
	Pack.Array(Pack.Int16),
	-- Common Roblox datatypes
	Pack.Color3,
	Pack.Vector3,
	Pack.CFrame,
	Pack.UDim2,
	-- DateTime
	Pack.DateTime,
	-- An enum item from the Font enum
	Pack.EnumItem(Enum.Font),
	-- Null/nil
	Pack.Null
))

-- A list of test cases for each branch of the Union
local testCases = {
	{ value = 255, desc = "UInt8" },
	{ value = -32768, desc = "Int16" },
	{ value = true, desc = "Boolean" },
	{ value = "union", desc = "String8" },
	{ value = nil, desc = "Null" },
	{ value = { true, false, true }, desc = "BitField(3)" },
	{ value = { A = 1, B = "b" }, desc = "Dictionary<{A:UInt8,B:String8}>" },
	{ value = { 10, 20, 30 }, desc = "Array<Int16>" },
	{ value = Color3.new(1, 0, 1), desc = "Color3" },
	{ value = Vector3.new(4, 5, 6), desc = "Vector3" },
	{ value = CFrame.new(7, 8, 9), desc = "CFrame" },
	{ value = UDim2.new(0, 10, 1, 20), desc = "UDim2" },
	{ value = DateTime.now(), desc = "DateTime" },
	{ value = Enum.Font.Arial, desc = "EnumItem(Font)" },
}

describe("Union", function()
	for _, case in testCases do
		it(`handles {case.desc} branch correctly`, function()
			local encoded = unionSchema:Write(case.value)
			local decoded = unionSchema:Read(encoded)
			expect(decoded).toEqual(case.value)
		end)
	end

	it("errors when given a value not represented by any branch", function()
		expect(function()
			-- {} is not a value supported by any of the union branches
			unionSchema:Write({ C = 1 })
		end).toThrow()
	end)
end)
