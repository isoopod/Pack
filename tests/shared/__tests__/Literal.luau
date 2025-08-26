local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

describe("Literal", function()
	it("should support literal boolean", function()
		local schema = Pack:Define(Pack.Literal(true))

		local packet = schema:Write()
		local output = schema:Read(packet)

		expect(output).toBeTruthy()
		expect(buffer.len(packet)).toEqual(0) -- Must always use 0 bytes
	end)

	it("should support literal number", function()
		local schema = Pack:Define(Pack.Literal(123))

		local packet = schema:Write()
		local output = schema:Read(packet)

		expect(output).toEqual(123)
		expect(buffer.len(packet)).toEqual(0)
	end)

	it("should support literal string", function()
		local schema = Pack:Define(Pack.Literal("hello"))

		local packet = schema:Write()
		local output = schema:Read(packet)

		expect(output).toEqual("hello")
		expect(buffer.len(packet)).toEqual(0)
	end)

	it("should support literal nil", function()
		local schema = Pack:Define(Pack.Literal(nil))

		local packet = schema:Write()
		local output = schema:Read(packet)

		expect(output).toBeNil()
		expect(buffer.len(packet)).toEqual(0)
	end)

	it("should support literal table", function()
		local lit = { a = 1, b = 2 }
		local schema = Pack:Define(Pack.Literal(lit))

		local packet = schema:Write()
		local output = schema:Read(packet)

		expect(output).toEqual(lit)
		expect(buffer.len(packet)).toEqual(0)
	end)
end)
