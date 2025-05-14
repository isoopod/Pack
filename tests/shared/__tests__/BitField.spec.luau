local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local function createTestArray(length: number, pattern: (number) -> boolean): { boolean }
	local arr = {}
	for i = 1, length do
		arr[i] = pattern(i)
	end
	return arr
end

describe("BitField", function()
	-- Standard cases
	it("should handle all bits false", function()
		local length = 8
		local input = createTestArray(length, function()
			return false
		end)
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		local output = schema:Read(packet)
		expect(output).toEqual(input)
		expect(buffer.len(packet)).toEqual((length + 7) // 8)
	end)

	it("should handle all bits true", function()
		local length = 16
		local input = createTestArray(length, function()
			return true
		end)
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		local output = schema:Read(packet)
		expect(output).toEqual(input)
		expect(buffer.len(packet)).toEqual((length + 7) // 8)
	end)

	it("should handle alternating bits", function()
		local length = 9
		local input = createTestArray(length, function(i)
			return i % 2 == 1
		end)
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		local output = schema:Read(packet)
		expect(output).toEqual(input)
		expect(buffer.len(packet)).toEqual((length + 7) // 8)
	end)

	-- Edge cases
	it("should handle single bit", function()
		local length = 1
		local input = { true }
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		local output = schema:Read(packet)
		expect(output).toEqual(input)
		expect(buffer.len(packet)).toEqual((length + 7) // 8)
	end)

	it("should handle length just above u8 chunk", function()
		local length = 9
		local input = createTestArray(length, function(i)
			return i == 1 or i == 9
		end)
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		local output = schema:Read(packet)
		expect(output).toEqual(input)
		expect(buffer.len(packet)).toEqual((length + 7) // 8)
	end)

	it("should handle length requiring u32 chunk", function()
		local length = 33
		local input = createTestArray(length, function(i)
			return i % 3 == 0
		end)
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		local output = schema:Read(packet)
		expect(output).toEqual(input)
		expect(buffer.len(packet)).toEqual((length + 7) // 8)
	end)

	-- Buffer length validation
	it("should validate buffer length for exact byte multiple", function()
		local length = 24 -- 3 bytes
		local input = createTestArray(length, function()
			return true
		end)
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		expect(buffer.len(packet)).toEqual(3)
	end)

	it("should validate buffer length for partial byte", function()
		local length = 7 -- 1 byte
		local input = createTestArray(length, function()
			return false
		end)
		local schema = Pack:Define(Pack.BitField(length))
		local packet = schema:Write(input)
		expect(buffer.len(packet)).toEqual(1)
	end)
end)
