local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local Region3Schema = Pack:Define(Pack.Region3)
local Region3int16Schema = Pack:Define(Pack.Region3int16)

local function isVectorClose(result: Vector2 | Vector3, original: Vector2 | Vector3)
	local axisList = typeof(original) == "Vector2" and { "X", "Y" } or { "X", "Y", "Z" }

	for _, axis in axisList do
		expect(result[axis]).toBeCloseTo(original[axis])
	end
end

describe("Region3", function()
	it("should correctly round-trip Region3 values", function()
		local min = Vector3.new(-10, -5, 2)
		local max = Vector3.new(20, 15, 12)
		local region = Region3.new(min, max)
		-- Position: 5, 5, 7
		-- Size: 30, 20, 10

		local packet = Region3Schema:Write(region)
		local result = Region3Schema:Read(packet)

		isVectorClose(result.CFrame.Position, region.CFrame.Position)
		isVectorClose(result.Size, region.Size)
	end)
end)

describe("Region3int16", function()
	it("should correctly round-trip Region3int16 values", function()
		local min = Vector3int16.new(-1000, -500, 200)
		local max = Vector3int16.new(1000, 500, 400)
		local region = Region3int16.new(min, max)

		local packet = Region3int16Schema:Write(region)
		local result = Region3int16Schema:Read(packet)

		expect(result.Min).toEqual(region.Min)
		expect(result.Max).toEqual(region.Max)
	end)
end)
