local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

-- Define a basic Lua class for testing
local MyClass = {}
MyClass.__index = MyClass

function MyClass.new(x: number)
	return setmetatable({ x = x }, MyClass)
end

function MyClass:add(y: number)
	self.x += y
end

-- classData: marshals an object with field 'x'
local schema = Pack:Define(Pack.Object(
	MyClass,
	Pack.Dictionary({
		x = Pack.Double,
	})
))

describe("Object", function()
	it("should round-trip object data and apply metatable", function()
		local original = MyClass.new(42)
		local buf = schema:Write(original)
		local result = schema:Read(buf)

		-- Underlying data
		expect(result.x).toBe(42)
		-- Metatable applied
		expect(getmetatable(result)).toBe(MyClass)
		-- Should not be the same reference
		expect(result).never.toBe(original)

		-- Verify class method still works
		result:add(8)
		expect(result.x).toBe(50)
		expect(original.x).toBe(42)
	end)
end)
