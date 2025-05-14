local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local schema = Pack:Define(Pack.Boolean)

describe("Boolean", function()
	-- Standard cases
	it("should serialize/deserialize true correctly", function()
		local input = true
		local packet = schema:Write(input)
		local output = schema:Read(packet)

		expect(output).toBeTruthy()
		expect(buffer.len(packet)).toEqual(1) -- Must always use 1 byte
	end)

	it("should serialize/deserialize false correctly", function()
		local input = false
		local packet = schema:Write(input)
		local output = schema:Read(packet)

		expect(output).toBeFalsy()
		expect(buffer.len(packet)).toEqual(1) -- Must always use 1 byte
	end)

	-- Edge case validation
	it("should handle repeated writes/reads", function()
		-- First write/read cycle
		local packet1 = schema:Write(true)
		expect(schema:Read(packet1)).toEqual(true)

		-- Second write/read cycle
		local packet2 = schema:Write(false)
		expect(schema:Read(packet2)).toEqual(false)
	end)
end)
