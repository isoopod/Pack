local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)
local types = require(ReplicatedStorage.Pack.types)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local function testBufferType(typeName: string, byteSize: number, maxLength: number)
	describe(typeName, function()
		local schema = Pack:Define(Pack[typeName])

		-- Standard cases
		it("should handle empty buffers", function()
			local emptyBuffer = buffer.create(0)
			local packet = schema:Write(emptyBuffer)
			local result = schema:Read(packet)

			expect(buffer.len(result)).toEqual(0)
			expect(buffer.len(packet)).toEqual(byteSize) -- Just length prefix
		end)

		it("should handle small buffers", function()
			local testBuffer = buffer.fromstring("small")
			local packet = schema:Write(testBuffer)
			local result = schema:Read(packet)

			expect(buffer.tostring(result)).toEqual("small")
			expect(buffer.len(packet)).toEqual(byteSize + 5) -- length prefix + content
		end)

		-- Buffer32 exceeds the 1GiB limit for buffers, so skip
		if byteSize ~= 4 then
			it("should handle maximum size buffers", function()
				local content = string.rep("x", maxLength)
				local testBuffer = buffer.fromstring(content)
				local packet = schema:Write(testBuffer)
				local result = schema:Read(packet)

				expect(buffer.tostring(result)).toEqual(content)
				expect(buffer.len(packet)).toEqual(byteSize + maxLength)
			end)
		end

		-- Error cases
		-- if maxLength < 2 ^ 32 - 1 then
		-- 	it("should error when buffer exceeds maximum length", function()
		-- 		local tooLarge = buffer.fromstring(string.rep("x", maxLength + 1))
		-- 		expect(function()
		-- 			schema:Write(tooLarge)
		-- 		end).toThrow()
		-- 	end)
		-- end

		-- Performance validation
		it("should maintain correct buffer length prefix", function()
			for i = 1, 10 do
				local testBuffer = buffer.fromstring(string.rep("x", i))
				local packet = schema:Write(testBuffer)

				-- Verify length prefix
				local lenPrefix = 0
				if byteSize == 1 then
					lenPrefix = buffer.readu8(packet, 0)
				elseif byteSize == 2 then
					lenPrefix = buffer.readu16(packet, 0)
				elseif byteSize == 3 then
					-- Read as 24-bit value (little endian)
					--selene:allow(incorrect_standard_library_use)
					lenPrefix = buffer.readbits(packet, 0, 24)
				elseif byteSize == 4 then
					lenPrefix = buffer.readu32(packet, 0)
				end

				expect(lenPrefix).toEqual(i)
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

				expect(buffer.len(result)).toEqual(length)
				expect(buffer.tostring(result)).toEqual(content)
			end)

			if length > 0 then
				it("should error when writing undersized buffers", function()
					local smallBuffer = buffer.fromstring(string.rep("a", length - 1))
					expect(function()
						schema:Write(smallBuffer)
					end).toThrow()
				end)
			end

			it("should error when writing oversized buffers", function()
				-- DEBUGGING --
				local s = pcall(function()
					local largeBuffer = buffer.fromstring(string.rep("a", length + 1))
					schema:Write(largeBuffer)
				end)
				if s then
					error(
						`Expected error when writing oversized buffer of length {length}, but write succeeded.\nBuffer length: {buffer.len(
							buffer.fromstring(string.rep("a", length + 1))
						)}\nDEBUG: {types.DEBUG ~= nil}`
					)
				end

				expect(function()
					-- Keep this inside the expect because this line will error at max buffer size
					local largeBuffer = buffer.fromstring(string.rep("a", length + 1))
					schema:Write(largeBuffer)
				end).toThrow()
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
