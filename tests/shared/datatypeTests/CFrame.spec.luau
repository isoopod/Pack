return function()
	local Pack = require(game:GetService("ReplicatedStorage").Pack)
	local schema = Pack:Define(Pack.CFrame)

	-- Helper to compare CFrames with tolerance
	local function expectCFrameNear(actual: CFrame, expected: CFrame, epsilon: number)
		local aPos, bPos = actual.Position, expected.Position
		expect(aPos.X).to.be.near(bPos.X, epsilon)
		expect(aPos.Y).to.be.near(bPos.Y, epsilon)
		expect(aPos.Z).to.be.near(bPos.Z, epsilon)

		-- Compare rotation matrix components
		local aRight, aUp, aLook = actual:GetComponents()
		local bRight, bUp, bLook = expected:Orthonormalize():GetComponents()

		for i, aVec in { aRight, aUp, aLook } do
			local bVec = select(i, bRight, bUp, bLook)
			for j = 1, 3 do
				expect(aVec[j]).to.be.near(bVec[j], epsilon)
			end
		end
	end

	describe("CFrame", function()
		-- Axis-aligned cases (13 bytes)
		describe("axis-aligned rotations", function()
			it("should handle identity CFrame", function()
				local input = CFrame.identity
				local packet = schema:Write(input)
				local output = schema:Read(packet)

				expectCFrameNear(output, input, 1e-5)
				expect(buffer.len(packet)).to.equal(13)
			end)

			it("should handle +X right/+Y up", function()
				local cf = CFrame.fromMatrix(Vector3.new(1, 2, 3), Vector3.xAxis, Vector3.yAxis)
				local packet = schema:Write(cf)
				local result = schema:Read(packet)

				expectCFrameNear(result, cf, 1e-5)
				expect(buffer.len(packet)).to.equal(13)
			end)

			it("should handle -Z right/-X up", function()
				local cf = CFrame.fromMatrix(Vector3.new(-5, 10, 0.5), -Vector3.zAxis, -Vector3.xAxis)
				local packet = schema:Write(cf)
				local result = schema:Read(packet)

				expectCFrameNear(result, cf, 1e-5)
				expect(buffer.len(packet)).to.equal(13)
			end)
		end)

		-- Non-axis-aligned cases (19 bytes)
		describe("arbitrary rotations", function()
			it("should handle 45° rotation on all axes", function()
				local cf = CFrame.fromEulerAnglesXYZ(math.rad(45), math.rad(45), math.rad(45)) + Vector3.new(10, -5, 3)

				local packet = schema:Write(cf)
				local result = schema:Read(packet)

				expectCFrameNear(result, cf, 1e-3) -- Higher tolerance due to quat compression
				expect(buffer.len(packet)).to.equal(19)
			end)

			it("should handle near-axis-aligned edge case", function()
				-- Almost axis-aligned but not quite
				local cf = CFrame.fromEulerAnglesXYZ(math.rad(0.1), math.rad(89.9), math.rad(0.1))
				local packet = schema:Write(cf)

				expect(buffer.len(packet)).to.equal(19) -- Should use full quaternion
			end)
		end)

		-- Precision & extreme values
		describe("precision validation", function()
			it("should handle large position values", function()
				local cf = CFrame.new(1e6, -2e5, 3.14e5) * CFrame.fromEulerAnglesXYZ(math.pi / 4, 0, 0)
				local packet = schema:Write(cf)
				local result = schema:Read(packet)

				expectCFrameNear(result, cf, 1e-2) -- Allow larger tolerance for large coordinates
			end)

			it("should reconstruct near-identity rotations", function()
				local cf = CFrame.fromEulerAnglesXYZ(math.rad(0.5), math.rad(0.5), math.rad(0.5))
				local result = schema:Read(schema:Write(cf))

				expectCFrameNear(result, cf, 1e-3)
			end)
		end)
	end)
end
