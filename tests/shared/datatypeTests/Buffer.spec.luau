return function()
	local Pack = require(game:GetService("ReplicatedStorage").Pack)

	local function testBufferType(typeName: string, byteSize: number, maxLength: number)
		describe(typeName, function()
			local schema = Pack:Define(Pack[typeName])

			-- Standard cases
			it("should handle empty buffers", function()
				local emptyBuffer = buffer.create(0)
				local packet = schema:Write(emptyBuffer)
				local result = schema:Read(packet)

				expect(buffer.len(result)).to.equal(0)
				expect(buffer.len(packet)).to.equal(byteSize) -- Just length prefix
			end)

			it("should handle small buffers", function()
				local testBuffer = buffer.fromstring("small")
				local packet = schema:Write(testBuffer)
				local result = schema:Read(packet)

				expect(buffer.tostring(result)).to.equal("small")
				expect(buffer.len(packet)).to.equal(byteSize + 5) -- length prefix + content
			end)

			-- Buffer32 exceeds the 1GiB limit for buffers, so skip
			if byteSize ~= 4 then
				it("should handle maximum size buffers", function()
					local content = string.rep("x", maxLength)
					local testBuffer = buffer.fromstring(content)
					local packet = schema:Write(testBuffer)
					local result = schema:Read(packet)

					expect(buffer.tostring(result)).to.equal(content)
					expect(buffer.len(packet)).to.equal(byteSize + maxLength)
				end)
			end

			-- Edge cases
			it("should handle binary data with null bytes", function()
				local binaryData = buffer.create(3)
				buffer.writeu8(binaryData, 0, 0)
				buffer.writeu8(binaryData, 1, 255)
				buffer.writeu8(binaryData, 2, 0)

				local packet = schema:Write(binaryData)
				local result = schema:Read(packet)

				expect(buffer.len(result)).to.equal(3)
				expect(buffer.readu8(result, 0)).to.equal(0)
				expect(buffer.readu8(result, 1)).to.equal(255)
				expect(buffer.readu8(result, 2)).to.equal(0)
			end)

			-- Error cases
			it("should error when buffer exceeds maximum length", function()
				if maxLength < math.huge then
					local tooLarge = buffer.fromstring(string.rep("x", maxLength + 1))
					expect(function()
						schema:Write(tooLarge)
					end).to.throw()
				end
			end)

			-- Performance validation
			it("should maintain correct buffer length prefix", function()
				for i = 1, math.min(10, maxLength) do
					local testBuffer = buffer.fromstring(string.rep("a", i))
					local packet = schema:Write(testBuffer)

					-- Verify length prefix
					local lenPrefix = 0
					if byteSize == 1 then
						lenPrefix = packet.readu8(0)
					elseif byteSize == 2 then
						lenPrefix = packet.readu16(0)
					elseif byteSize == 3 then
						-- Read as 24-bit value (little endian)
						lenPrefix = packet.readu8(0) + (bit32.lshift(packet.readu8(1), 8)) + (bit32.lshift(packet.readu8(2), 16))
					elseif byteSize == 4 then
						lenPrefix = packet.readu32(0)
					end

					expect(lenPrefix).to.equal(i)
				end
			end)
		end)
	end

	-- Test all buffer variants
	testBufferType("Buffer8", 1, 2 ^ 8 - 1) -- 8-bit (1 byte) length prefix
	testBufferType("Buffer16", 2, 2 ^ 16 - 1) -- 16-bit (2 byte) length prefix
	testBufferType("Buffer24", 3, 2 ^ 24 - 1) -- 24-bit (3 byte) length prefix
	testBufferType("Buffer32", 4, 2 ^ 32 - 1) -- 32-bit (4 byte) length prefix (effectively unlimited)

	-- BufferFixed
	describe("BufferFixed", function()
		local function testFixedBuffer(length: number)
			describe(`with length {length}`, function()
				local schema = Pack:Define(Pack.BufferFixed(length))

				it("should read/write exact length buffers", function()
					-- Create test content that exactly matches the fixed length
					local content = string.rep("x", length)
					local testBuffer = buffer.fromstring(content)

					local packet = schema:Write(testBuffer)
					local result = schema:Read(packet)

					expect(buffer.len(result)).to.equal(length)
					expect(buffer.tostring(result)).to.equal(content)
				end)

				it("should handle binary data with null bytes", function()
					local binaryBuffer = buffer.create(length)
					-- Write alternating 0 and 255 bytes
					for i = 0, length - 1 do
						buffer.writeu8(binaryBuffer, i, i % 2 == 0 and 0 or 255)
					end

					local packet = schema:Write(binaryBuffer)
					local result = schema:Read(packet)

					expect(buffer.len(result)).to.equal(length)
					-- Verify pattern was preserved
					for i = 0, length - 1 do
						expect(buffer.readu8(result, i)).to.equal(i % 2 == 0 and 0 or 255)
					end
				end)

				if length > 0 then
					it("should error when writing undersized buffers", function()
						local smallBuffer = buffer.fromstring(string.rep("a", length - 1))
						expect(function()
							schema:Write(smallBuffer)
						end).to.throw()
					end)
				end

				it("should error when writing oversized buffers", function()
					local largeBuffer = buffer.fromstring(string.rep("a", length + 1))
					expect(function()
						schema:Write(largeBuffer)
					end).to.throw()
				end)
			end)
		end

		-- Test various fixed lengths
		testFixedBuffer(0) -- Edge case: zero-length buffer
		testFixedBuffer(1) -- Minimum non-zero length
		testFixedBuffer(16) -- Small power-of-two
		testFixedBuffer(255) -- Max single-byte length
		testFixedBuffer(1024) -- Typical larger buffer
		testFixedBuffer(2 ^ 30) -- Max buffer length
	end)
end
