local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

describe("UDim", function()
	local schema = Pack:Define(Pack.UDim)
	local testValues = {
		UDim.new(0, 0),
		UDim.new(1, 100),
		UDim.new(-1.5, -50),
		UDim.new(0.3333333, 32767),
		UDim.new(3.14159, -32768),
	}

	it("writes buffer length correctly", function()
		for _, value in testValues do
			local packet = schema:Write(value)
			expect(buffer.len(packet)).toBe(6)
		end
	end)

	it("round-trips both components accurately", function()
		for _, original in testValues do
			local packet = schema:Write(original)
			local result = schema:Read(packet)

			expect(result.Scale).toBeCloseTo(original.Scale, 5)
			expect(result.Offset).toBe(original.Offset)
		end
	end)
end)

describe("UDim2", function()
	local schema = Pack:Define(Pack.UDim2)
	local testValues = {
		UDim2.new(0, 0, 0, 0),
		UDim2.new(1, 10, 2, 20),
		UDim2.new(-0.5, -100, 0.5, 100),
		UDim2.new(3.14, 32767, -3.14, -32768),
	}

	it("writes buffer length correctly", function()
		for _, value in testValues do
			local packet = schema:Write(value)
			expect(buffer.len(packet)).toBe(12)
		end
	end)

	it("round-trips both components accurately", function()
		for _, original in testValues do
			local packet = schema:Write(original)
			local result = schema:Read(packet)

			expect(result.X.Scale).toBeCloseTo(original.X.Scale, 5)
			expect(result.X.Offset).toBe(original.X.Offset)
			expect(result.Y.Scale).toBeCloseTo(original.Y.Scale, 5)
			expect(result.Y.Offset).toBe(original.Y.Offset)
		end
	end)
end)
