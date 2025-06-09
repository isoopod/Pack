local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

-- Schema for mixed-key dictionary (string and numeric keys)
local mixedSchema = Pack:Define(Pack.Dictionary({
	A = Pack.UInt8,
	B = Pack.String16,
	[0] = Pack.Float32,
	C = Pack.Boolean,
}))

-- Schema for nested dictionary
local nestedSchema = Pack:Define(Pack.Dictionary({
	Outer = Pack.UInt16,
	Inner = Pack.Dictionary({
		X = Pack.Int8,
		Y = Pack.String8,
	}),
}))

describe("Mixed Table Dictionaries", function()
	it("Writes and Reads a mixed-key table correctly", function()
		local expected = {
			A = 42,
			B = "hello",
			[0] = 2.718,
			C = true,
		}
		local encoded = mixedSchema:Write(expected)
		local actual = mixedSchema:Read(encoded)
		expect(actual).toEqual(expected)
	end)

	it("ignores insertion order when encoding mixed-key tables", function()
		local t1 = { A = 1, B = "x", [0] = 0.1, C = false }

		local t2 = {}
		t2.C = false
		t2[0] = 0.1
		t2.B = "x"
		t2.A = 1

		local enc1 = mixedSchema:Write(t1)
		local enc2 = mixedSchema:Write(t2)
		expect(enc1).toEqual(enc2)
	end)

	it("produces distinct encodings for different mixed-key values", function()
		local base = { A = 10, B = "foo", [0] = 1.5, C = true }
		local modified = { A = 10, B = "foo", [0] = 1.5, C = false }

		local encBase = mixedSchema:Write(base)
		local encMod = mixedSchema:Write(modified)
		expect(buffer.tostring(encBase)).never.toEqual(buffer.tostring(encMod))
	end)
end)

describe("Nested Dictionaries", function()
	it("Writes and Reads a nested dictionary correctly", function()
		local expected = {
			Outer = 65535,
			Inner = {
				X = -128,
				Y = "NZ",
			},
		}
		local encoded = nestedSchema:Write(expected)
		local actual = nestedSchema:Read(encoded)
		expect(actual).toEqual(expected)
	end)

	it("handles edge values in nested dictionaries", function()
		local edge = {
			Outer = 0,
			Inner = {
				X = 127,
				Y = "",
			},
		}
		local enc = nestedSchema:Write(edge)
		local dec = nestedSchema:Read(enc)
		expect(dec).toEqual(edge)
	end)

	it("detects changes in nested fields", function()
		local original = {
			Outer = 100,
			Inner = { X = 1, Y = "a" },
		}
		local changed = {
			Outer = 100,
			Inner = { X = 2, Y = "a" },
		}

		local encOrig = nestedSchema:Write(original)
		local encChanged = nestedSchema:Write(changed)
		expect(buffer.tostring(encOrig)).never.toEqual(buffer.tostring(encChanged))
	end)
end)
