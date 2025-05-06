return function()
	local Pack = require(game:GetService("ReplicatedStorage").Pack)
	local schemaModule = Pack.BrickColor

	describe("BrickColor", function()
		-- Standard color cases
		it("should serialize/deserialize common colors correctly", function()
			local schema = Pack:Define(schemaModule)
			local testColors = {
				BrickColor.new("Bright red"),
				BrickColor.new("Bright blue"),
				BrickColor.new("Medium green"),
				BrickColor.new("White"),
				BrickColor.new("Black"),
			}

			for _, color in testColors do
				local b = schema:Write(color)
				local result = schema:Read(buffer)

				expect(result).to.equal(color)
				expect(buffer.len(b)).to.equal(2) -- Must always use 2 bytes
			end
		end)

		-- Edge cases
		it("should handle first and last palette colors", function()
			local schema = Pack:Define(schemaModule)

			-- First color in default palette (1 - White)
			local firstColor = BrickColor.new(1)
			local firstBuffer = schema:Write(firstColor)
			expect(schema:Read(firstBuffer)).to.equal(firstColor)

			-- Last color in default palette (192 - Sand red)
			local lastColor = BrickColor.new(192)
			local lastBuffer = schema:Write(lastColor)
			expect(schema:Read(lastBuffer)).to.equal(lastColor)
		end)

		-- Round-trip consistency
		it("should maintain consistency through multiple serializations", function()
			local schema = Pack:Define(schemaModule)
			local color = BrickColor.new("Lime green")

			-- First serialization
			local buffer1 = schema:Write(color)
			local result1 = schema:Read(buffer1)

			-- Second serialization
			local buffer2 = schema:Write(result1)
			local result2 = schema:Read(buffer2)

			expect(result1).to.equal(color)
			expect(result2).to.equal(color)
			expect(buffer1).to.equal(buffer2) -- Buffers should be identical
		end)
	end)
end
