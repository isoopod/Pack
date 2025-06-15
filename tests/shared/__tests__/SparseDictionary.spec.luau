local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

-- Sparse dictionary schema: some keys optional, some required
local schema = Pack:Define(Pack.SparseDictionary({ OptionalA = Pack.UInt8, OptionalB = Pack.String8 }, { RequiredX = Pack.Int16, RequiredY = Pack.String8 }))

describe("SparseDictionary", function()
	it("encodes and decodes when no optional fields present", function()
		local input = {
			RequiredX = -1000,
			RequiredY = "true",
		}
		local encoded = schema:Write(input)
		local decoded = schema:Read(encoded)
		expect(decoded).toEqual(input)
	end)

	it("encodes and decodes when all optional fields present", function()
		local input = {
			OptionalA = 255,
			OptionalB = "nz",
			RequiredX = 0,
			RequiredY = "false",
		}
		local encoded = schema:Write(input)
		local decoded = schema:Read(encoded)
		expect(decoded).toEqual(input)
	end)

	it("encodes and decodes when some optional fields present", function()
		local input = {
			OptionalB = "",
			RequiredX = 123,
			RequiredY = "false",
		}
		local encoded = schema:Write(input)
		local decoded = schema:Read(encoded)
		expect(decoded).toEqual(input)
	end)

	it("errors when missing some required keys", function()
		local input = {
			OptionalA = 255,
			OptionalB = "a",
			RequiredX = 123,
		}

		expect(function()
			schema:Write(input)
		end).toThrow()
	end)

	it("ignores insertion order for optional and required fields", function()
		local t1 = {
			OptionalA = 1,
			OptionalB = "a",
			RequiredX = 1,
			RequiredY = "false",
		}
		local t2 = {}
		t2.RequiredY = "false"
		t2.OptionalB = "a"
		t2.RequiredX = 1
		t2.OptionalA = 1

		local enc1 = schema:Write(t1)
		local enc2 = schema:Write(t2)
		expect(buffer.tostring(enc1)).toEqual(buffer.tostring(enc2))
	end)

	it("produces distinct encodings when optional presence differs", function()
		local base = { RequiredX = 5, RequiredY = "true" }
		local withOpt = { OptionalA = 5, RequiredX = 5, RequiredY = "true" }

		local encBase = schema:Write(base)
		local encOpt = schema:Write(withOpt)
		expect(buffer.tostring(encBase)).never.toEqual(buffer.tostring(encOpt))
	end)

	it("detects changes in nested values correctly", function()
		-- change in a required field
		local orig = { OptionalA = 10, RequiredX = -1, RequiredY = "true" }
		local changed = { OptionalA = 10, RequiredX = 0, RequiredY = "true" }

		local encOrig = schema:Write(orig)
		local encChanged = schema:Write(changed)
		expect(buffer.tostring(encOrig)).never.toEqual(buffer.tostring(encChanged))
	end)
end)
