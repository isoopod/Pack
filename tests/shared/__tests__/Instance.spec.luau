local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local schema = Pack:Define(Pack.Instance)

describe("Instance", function()
	it("should round-trip a new Instance", function()
		local inst = Instance.new("Folder")
		inst.Parent = workspace

		local buf = schema:Write(inst)
		local result = schema:Read(buf)

		expect(result).toBe(inst)
	end)

	it("should assign a persistent tag on write and reuse on subsequent writes", function()
		local inst = Instance.new("Folder")
		inst.Parent = workspace

		-- First write assigns a tag
		schema:Write(inst)
		local tagsAfterFirst = inst:GetTags()
		expect(#tagsAfterFirst).toBe(1)

		-- Second write should not add additional tags
		schema:Write(inst)
		local tagsAfterSecond = inst:GetTags()
		expect(#tagsAfterSecond).toBe(#tagsAfterFirst)
	end)

	it("should generate distinct refs for different instances", function()
		local inst1 = Instance.new("Folder")
		inst1.Parent = workspace

		local inst2 = Instance.new("Folder")
		inst2.Parent = workspace

		schema:Write(inst1)
		schema:Write(inst2)

		local tag1 = inst1:GetTags()[1]
		local tag2 = inst2:GetTags()[1]
		expect(tag1).never.toBe(tag2)
	end)

	it("should return nil when reading an unknown ref", function()
		-- Create a fake buffer with ref index not matching any tagged instance
		local packet = buffer.fromstring("FFFF") -- Arbitrary large 4 byte number
		local result = schema:Read(packet)
		expect(result).toBeNil()
	end)
end)
