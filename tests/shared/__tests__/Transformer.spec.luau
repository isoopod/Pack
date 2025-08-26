local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

describe("Transformer", function()
	it("should round trip values with encode and decode", function()
		-- Base format is u32
		local schema = Pack:Define(Pack.Transformer(Pack.u32, function(value: string)
			-- Encode: turn string into its length
			return #value
		end, function(value: number)
			-- Decode: rebuild string of 'a' repeated length times
			return string.rep("a", value)
		end))

		local input = "aaaaa"
		local encoded = schema:Write(input)
		local decoded = schema:Read(encoded)

		expect(decoded).toBe(input)
	end)

	it("should change format with only encode", function()
		-- Base format is u32, but encode changes from boolean
		local schema = Pack:Define(Pack.Transformer(Pack.u32, function(value: boolean)
			-- Encode true/false into 1/0
			return value and 1 or 0
		end))

		local encodedTrue = schema:Write(true)
		local decodedTrue = schema:Read(encodedTrue) -- will just be raw u32
		expect(decodedTrue).toBe(1)

		local encodedFalse = schema:Write(false)
		local decodedFalse = schema:Read(encodedFalse)
		expect(decodedFalse).toBe(0)
	end)

	it("should validate input with only decode", function()
		-- Base format is u32, decode restricts values
		local schema = Pack:Define(Pack.Transformer(Pack.u32, nil, function(value: number)
			if value ~= 42 then error("Invalid value") end
			return "ok"
		end))

		-- Valid case
		local encoded = schema:Write(42)
		local decoded = schema:Read(encoded)
		expect(decoded).toBe("ok")

		-- Invalid case should throw
		local badEncoded = schema:Write(13)
		expect(function()
			schema:Read(badEncoded)
		end).toThrow()
	end)
end)
