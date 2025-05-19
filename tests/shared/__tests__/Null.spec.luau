local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local schema = Pack:Define(Pack.Null)

describe("Null", function()
	it("should be nil", function()
		local packet = schema:Write()
		local actual = schema:Read(packet)

		expect(actual).toBeNil()
	end)

	it("should use 0 bytes", function()
		local packet = schema:Write()

		expect(buffer.len(packet)).toBe(0)
	end)
end)
