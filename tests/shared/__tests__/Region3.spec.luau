local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local Region3Schema = Pack:Define(Pack.Region3)
local Region3int16Schema = Pack:Define(Pack.Region3int16)

describe("Region3", function()
	it("should correctly round-trip Region3 values", function()
		local min = Vector3.new(-10, -5, 2)
		local max = Vector3.new(20, 15, 12)
		local region = Region3.new(min, max)

		local packet = Region3Schema:Write(region)
		local result = Region3Schema:Read(packet)

		expect(result.CFrame.Position).toBeApproximately(region.CFrame.Position, 1e-3)
		expect(result.Size).toBeApproximately(region.Size, 1e-3)
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
