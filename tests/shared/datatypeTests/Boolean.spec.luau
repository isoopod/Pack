return function()
	local Pack = require(game:GetService("ReplicatedStorage").Pack)
	local schema = Pack:Define(Pack.Boolean)

	describe("Boolean", function()
		-- Standard cases
		it("should serialize/deserialize true correctly", function()
			local input = true
			local packet = schema:Write(input)
			local output = schema:Read(packet)

			expect(output).to.equal(true)
			expect(buffer.len(packet)).to.equal(1) -- Must always use 1 byte
		end)

		it("should serialize/deserialize false correctly", function()
			local input = false
			local packet = schema:Write(input)
			local output = schema:Read(packet)

			expect(output).to.equal(false)
			expect(buffer.len(packet)).to.equal(1) -- Must always use 1 byte
		end)

		-- Edge case validation
		it("should handle repeated writes/reads", function()
			-- First write/read cycle
			local packet1 = schema:Write(true)
			expect(schema:Read(packet1)).to.equal(true)

			-- Second write/read cycle
			local packet2 = schema:Write(false)
			expect(schema:Read(packet2)).to.equal(false)
		end)
	end)
end
