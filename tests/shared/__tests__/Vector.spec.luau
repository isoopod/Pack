local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local Pack = require(ReplicatedStorage.Pack)

local it = JestGlobals.it
local expect = JestGlobals.expect
local describe = JestGlobals.describe

local tests = {
	{
		name = "Vector3float16",
		key = Pack.Vector3float16,
		byteSize = 6,
		values = {
			vector.create(0, 0, 0),
			vector.create(1, -1, 0.5),
			vector.create(123.456, -654.321, 3.14),
		},
		digits = 0,
	},
	{
		name = "Vector3float24",
		key = Pack.Vector3float24,
		byteSize = 9,
		values = {
			vector.create(0, 0, 0),
			vector.create(1, -1, 0.5),
			vector.create(123.456, -654.321, 3.14),
		},
		digits = 2,
	},
	{
		name = "Vector3float32",
		key = Pack.Vector3,
		byteSize = 12,
		values = {
			vector.create(0, 0, 0),
			vector.create(1, -1, 0.5),
			vector.create(123.456, -654.321, 3.14),
		},
		digits = 6,
	},
	{
		name = "Vector3int16",
		key = Pack.Vector3int16,
		byteSize = 6,
		values = {
			vector.create(0, 0, 0),
			vector.create(32767, -32768, 1234),
			vector.create(-100, 100, -200),
		},
	},
	{
		name = "Vector2float16",
		key = Pack.Vector2float16,
		byteSize = 4,
		values = {
			Vector2.new(0, 0),
			Vector2.new(1, -1),
			Vector2.new(123.456, -654.321),
		},
		digits = 0,
	},
	{
		name = "Vector2float24",
		key = Pack.Vector2float24,
		byteSize = 6,
		values = {
			Vector2.new(0, 0),
			Vector2.new(1, -1),
			Vector2.new(123.456, -654.321),
		},
		digits = 2,
	},
	{
		name = "Vector2float32",
		key = Pack.Vector2,
		byteSize = 8,
		values = {
			Vector2.new(0, 0),
			Vector2.new(1, -1),
			Vector2.new(123.456, -654.321),
		},
		digits = 6,
	},
	{
		name = "Vector2int16",
		key = Pack.Vector2int16,
		byteSize = 4,
		values = {
			Vector2.new(0, 0),
			Vector2.new(32767, -32768),
			Vector2.new(-100, 200),
		},
	},
}

for _, spec in tests do
	describe(spec.name .. " datatype read/write", function()
		local schema = Pack:Define(spec.key)

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
				local axisList = typeof(original) == "Vector2" and { "X", "Y" } or { "X", "Y", "Z" }

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
