return function()
	local Pack = require(game:GetService("ReplicatedStorage").Pack)
	local schema = Pack:Define(Pack.BitField)

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
			local packet = schema:Write(input)
			local output = schema:Read(packet)
			expect(output).to.equal(input)
			expect(buffer.len(packet)).to.equal((length + 7) // 8)
		end)

		it("should handle all bits true", function()
			local length = 16
			local input = createTestArray(length, function()
				return true
			end)
			local packet = schema:Write(input)
			local output = schema:Read(packet)
			expect(output).to.equal(input)
			expect(buffer.len(packet)).to.equal((length + 7) // 8)
		end)

		it("should handle alternating bits", function()
			local length = 9
			local input = createTestArray(length, function(i)
				return i % 2 == 1
			end)
			local packet = schema:Write(input)
			local output = schema:Read(packet)
			expect(output).to.equal(input)
			expect(buffer.len(packet)).to.equal((length + 7) // 8)
		end)

		-- Edge cases
		it("should handle single bit", function()
			local length = 1
			local input = { true }
			local packet = schema:Write(input)
			local output = schema:Read(packet)
			expect(output).to.equal(input)
			expect(buffer.len(packet)).to.equal((length + 7) // 8)
		end)

		it("should handle length just above u8 chunk", function()
			local length = 9
			local input = createTestArray(length, function(i)
				return i == 1 or i == 9
			end)
			local packet = schema:Write(input)
			local output = schema:Read(packet)
			expect(output).to.equal(input)
			expect(buffer.len(packet)).to.equal((length + 7) // 8)
		end)

		it("should handle length requiring u32 chunk", function()
			local length = 33
			local input = createTestArray(length, function(i)
				return i % 3 == 0
			end)
			local packet = schema:Write(input)
			local output = schema:Read(packet)
			expect(output).to.equal(input)
			expect(buffer.len(packet)).to.equal((length + 7) // 8)
		end)

		-- Buffer length validation
		it("should validate buffer length for exact byte multiple", function()
			local length = 24 -- 3 bytes
			local input = createTestArray(length, function()
				return true
			end)
			local packet = schema:Write(input)
			expect(buffer.len(packet)).to.equal(3)
		end)

		it("should validate buffer length for partial byte", function()
			local length = 7 -- 1 byte
			local input = createTestArray(length, function()
				return false
			end)
			local packet = schema:Write(input)
			expect(buffer.len(packet)).to.equal(1)
		end)
	end)
end
