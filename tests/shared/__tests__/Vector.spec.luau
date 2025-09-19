local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local tests = {
	{
		name = "Vector3 float16",
		schema = Pack:Define(Pack.Vector3(Pack.Float16)),
		byteSize = 6,
		threeAxis = true,
		values = {
			vector.create(0, 0, 0),
			vector.create(1, -1, 0.5),
			vector.create(123.456, -654.321, 3.14),
		},
		digits = 0,
	},
	{
		name = "Vector3 float24",
		schema = Pack:Define(Pack.Vector3(Pack.Float24)),
		byteSize = 9,
		threeAxis = true,
		values = {
			vector.create(0, 0, 0),
			vector.create(1, -1, 0.5),
			vector.create(123.456, -654.321, 3.14),
		},
		digits = 2,
	},
	{
		name = "Vector3 float32",
		schema = Pack:Define(Pack.Vector3),
		byteSize = 12,
		threeAxis = true,
		values = {
			vector.create(0, 0, 0),
			vector.create(1, -1, 0.5),
			vector.create(123.456, -654.321, 3.14),
		},
		digits = 6,
	},
	{
		name = "Vector3int16",
		schema = Pack:Define(Pack.Vector3int16),
		byteSize = 6,
		threeAxis = true,
		values = {
			Vector3int16.new(0, 0, 0),
			Vector3int16.new(32767, -32768, 1234),
			Vector3int16.new(-100, 100, -200),
		},
	},
	{
		name = "Vector2 float16",
		schema = Pack:Define(Pack.Vector2(Pack.Float16)),
		byteSize = 4,
		values = {
			Vector2.new(0, 0),
			Vector2.new(1, -1),
			Vector2.new(123.456, -654.321),
		},
		digits = 0,
	},
	{
		name = "Vector2 float24",
		schema = Pack:Define(Pack.Vector2(Pack.Float24)),
		byteSize = 6,
		values = {
			Vector2.new(0, 0),
			Vector2.new(1, -1),
			Vector2.new(123.456, -654.321),
		},
		digits = 2,
	},
	{
		name = "Vector2 float32",
		schema = Pack:Define(Pack.Vector2),
		byteSize = 8,
		values = {
			Vector2.new(0, 0),
			Vector2.new(1, -1),
			Vector2.new(123.456, -654.321),
		},
		digits = 6,
	},
	{
		name = "Vector2 int16",
		schema = Pack:Define(Pack.Vector2int16),
		byteSize = 4,
		values = {
			Vector2int16.new(0, 0),
			Vector2int16.new(32767, -32768),
			Vector2int16.new(-100, 200),
		},
	},
}

for _, spec in tests do
	describe(spec.name .. " datatype read/write", function()
		local schema = spec.schema

		it("writes correct length", function()
			for _, value in spec.values do
				local packet = schema:Write(value)
				expect(buffer.len(packet)).toBe(spec.byteSize)
			end
		end)

		it("round-trips values", function()
			for _, original in spec.values do
				local packet = schema:Write(original)
				local result = schema:Read(packet)
				local axisList = spec.threeAxis and { "X", "Y", "Z" } or { "X", "Y" }

				if spec.digits then
					for _, axis in axisList do
						expect(result[axis]).toBeCloseTo(original[axis], spec.digits)
					end
				else
					for _, axis in axisList do
						expect(result[axis]).toBe(original[axis])
					end
				end
			end
		end)
	end)
end
