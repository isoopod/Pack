--!strict
--!optimize 2
--!native

local types = require(script.Parent.types)

type evaluators = {
	[string]: (value: any, datatype: types.DatatypeInterface<any>) -> boolean,
}

-- HELPERS --

-- Precomputed maximum normal values for each float format
local MAX_F16 = (2 ^ (2 ^ 5 - 1 - 1)) * (2 - 2 ^ -10) -- 5‑bit exponent, 10‑bit mantissa
local MAX_F24 = (2 ^ (2 ^ 7 - 1 - 1)) * (2 - 2 ^ -16) -- 7‑bit exponent, 16‑bit mantissa
local MAX_F32 = (2 ^ (2 ^ 8 - 1 - 1)) * (2 - 2 ^ -23) -- 8‑bit exponent, 23‑bit mantissa

-- Fuzzy equality check for floating point numbers
local function fuzzyEq(a: number, b: number, epsilon: number): boolean
	return math.abs(a - b) <= epsilon * math.max(1, math.abs(a), math.abs(b))
end

-- Test whether a value is exactly representable in an IEEE float
local function CanRepresent(value: number, maxRange: number, mantissaBits: number): boolean
	if math.abs(value) > maxRange then return false end
	-- Scale up by mantissa and back to check exactness
	local scale = 2 ^ mantissaBits
	local approx = math.round(value * scale) / scale
	return fuzzyEq(value, approx, 1e-9)
end

local function checkVector2(value: any, maxAbs: number)
	if typeof(value) ~= "Vector2" then return false end
	local comps = { value.X, value.Y }
	for _, c in comps do
		if c < -maxAbs or c > maxAbs then return false end
	end
	return true
end

local function checkVector3(value: any, maxAbs: number)
	if typeof(value) ~= "Vector3" then return false end
	local comps = { value.X, value.Y, value.Z }
	for _, c in comps do
		if c < -maxAbs or c > maxAbs then return false end
	end
	return true
end

local evaluator = {}

function evaluator.addEvaluator(Eval: string, func: (value: any, datatype: types.DatatypeInterface<any>) -> boolean)
	evaluator.evaluators[Eval] = func
end

evaluator.evaluators = {
	Any = function()
		return true
	end,
	Array = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		local of = datatype.Of
		local ofEval = of and of.Eval
		if ofEval and type(value) == "table" then
			local expectedIndex = 1
			for i, v in value do
				if i ~= expectedIndex then return false end
				if not evaluator.evaluators[ofEval](v, of) then return false end
				expectedIndex += 1
			end
			return true
		end
		return false
	end,
	BitField = function(value: unknown)
		if type(value) == "table" then
			local expectedIndex = 1
			for i, v in value do
				if i ~= expectedIndex then return false end
				if type(v) ~= "boolean" then return false end
				expectedIndex += 1
			end
			return true
		end
		return false
	end,
	bool = function(value: unknown)
		return type(value) == "boolean"
	end,
	BrickColor = function(value: unknown)
		return typeof(value) == "BrickColor"
	end,
	buffer8 = function(value: unknown)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 8 then return true end
		end
		return false
	end,
	buffer16 = function(value: unknown)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 16 then return true end
		end
		return false
	end,
	buffer24 = function(value: unknown)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 24 then return true end
		end
		return false
	end,
	buffer32 = function(value: unknown)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 32 then return true end
		end
		return false
	end,
	buffer = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		if datatype.len and type(value) == "buffer" then
			if buffer.len(value) < datatype.len then return true end
		end
		return false
	end,
	CFrame = function(value: unknown)
		return typeof(value) == "CFrame"
	end,
	Color3 = function(value: unknown)
		if typeof(value) == "Color3" then
			if value.R < 256 and value.G < 256 and value.B < 256 then return true end
		end
		return false
	end,
	Color3Raw = function(value: unknown)
		return typeof(value) == "Color3"
	end,
	DateTime = function(value: unknown)
		return typeof(value) == "DateTime"
	end,
	Dict = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		local _format = datatype.format
		if _format and type(value) == "table" then
			local format = _format :: any -- FIXME: If the luau evaluator ever fixes this, remove this cast
			-- First check number of keys
			local vLen, fLen = 0, 0
			for _ in value do
				vLen += 1
			end
			for _ in format do
				fLen += 1
			end
			if vLen ~= fLen then return false end

			for k, v in value do
				if not format[k] then return false end
				if not format[k].Eval then return false end
				if not evaluator.evaluators[format[k].Eval](v, format[k]) then return false end
			end
			return true
		end
		return false
	end,
	Enum = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		-- TODO: Look for a faster way to do this
		if datatype.Item then
			for _, v in (datatype.Item :: Enum):GetEnumItems() do
				if value == v then return true end
			end
		end
		return false
	end,
	f16 = function(value: unknown)
		if type(value) ~= "number" then return false end
		return CanRepresent(value, MAX_F16, 10)
	end,
	f24 = function(value: unknown)
		if type(value) ~= "number" then return false end
		return CanRepresent(value, MAX_F24, 16)
	end,
	f32 = function(value: unknown)
		if type(value) ~= "number" then return false end
		return CanRepresent(value, MAX_F32, 23)
	end,
	f64 = function(value: unknown)
		return type(value) == "number"
	end,
	Inst_Ref = function(value: unknown)
		return typeof(value) == "Instance"
	end,
	i8 = function(value: unknown)
		return type(value) == "number" and value >= -(2 ^ 8) and value <= (2 ^ 8 - 1) and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	i16 = function(value: unknown)
		return type(value) == "number" and value >= -(2 ^ 16) and value <= (2 ^ 16 - 1) and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	i32 = function(value: unknown)
		return type(value) == "number" and value >= -(2 ^ 32) and value <= (2 ^ 32 - 1) and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	Map = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		local key, val = datatype.Key, datatype.Val
		if key and val and key.Eval and val.Eval and type(value) == "table" then
			for k, v in value do
				if not evaluator.evaluators[key.Eval :: any](k, key :: any) then return false end
				if not evaluator.evaluators[val.Eval :: any](v, val :: any) then return false end
			end
			return true
		end
		return false
	end,
	["nil"] = function(value: unknown)
		return value == nil
	end,
	nullable = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		if not datatype.dt or not datatype.dt.Eval then return false end
		return value == nil or evaluator.evaluators[datatype.dt.Eval :: any](value, datatype.dt :: any)
	end,
	object = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		if type(value) ~= "table" or not datatype.mt or not datatype.cData or not (datatype.cData :: any).Eval then return false end
		if getmetatable(value :: any) ~= datatype.mt then return false end
		return evaluator.evaluators[datatype.cData.Eval :: any](value, datatype.cData :: any)
	end,
	R3 = function(value: unknown)
		return typeof(value) == "Region3"
	end,
	R3i16 = function(value: unknown)
		return typeof(value) == "Region3int16"
	end,
	SDict = function(_value: unknown, datatype: types.DatatypeInterface<unknown>)
		local format, optFormat = datatype.format, datatype.optFormat
		-- must be a table
		if not format or not optFormat or typeof(_value) ~= "table" then return false end
		local value: { [any]: any } = _value :: any

		local required: { [any]: any } = format or {}
		local optional = optFormat :: any
		local reqCount, optCount, valCount = 0, 0, 0

		-- count required, optional, and actual keys
		for _ in required do
			reqCount += 1
		end
		for _ in optional do
			optCount += 1
		end
		for _ in value do
			valCount += 1
		end

		-- too few or too many keys?
		if valCount < reqCount or valCount > (reqCount + optCount) then return false end

		for key, def in required do
			local v = rawget(value, key)
			if not def.Eval then return false end
			if v == nil then return false end
			if not evaluator.evaluators[def.Eval](v, def :: any) then return false end
		end

		for key, v in value do
			if required[key] then
				-- already validated
				continue
			end

			local def = optional[key]
			if def then
				if def.Eval and v then
					if not evaluator.evaluators[(def :: any).Eval](v, def :: any) then return false end
				end
			else
				return false
			end
		end

		return true
	end,
	s8 = function(value: unknown)
		if type(value) ~= "string" then return false end
		return buffer.len(buffer.fromstring(value)) < 2 ^ 8
	end,
	s16 = function(value: unknown)
		if type(value) ~= "string" then return false end
		return buffer.len(buffer.fromstring(value)) < 2 ^ 16
	end,
	s24 = function(value: unknown)
		if type(value) ~= "string" then return false end
		return buffer.len(buffer.fromstring(value)) < 2 ^ 24
	end,
	s32 = function(value: unknown)
		return type(value) == "string"
	end,
	string = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		if type(value) ~= "string" or not datatype.len then return false end
		return buffer.len(buffer.fromstring(value)) == datatype.len
	end,
	UD = function(value: unknown)
		return typeof(value) == "UDim"
	end,
	UD2 = function(value: unknown)
		return typeof(value) == "UDim2"
	end,
	u8 = function(value: unknown)
		return type(value) == "number" and value >= 0 and value < 2 ^ 8 and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	u16 = function(value: unknown)
		return type(value) == "number" and value >= 0 and value < 2 ^ 16 and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	u32 = function(value: unknown)
		return type(value) == "number" and value >= 0 and value < 2 ^ 32 and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	V2f16 = function(value: unknown)
		return checkVector2(value, MAX_F16)
	end,
	V2f24 = function(value: unknown)
		return checkVector2(value, MAX_F24)
	end,
	V2f32 = function(value: unknown)
		return checkVector2(value, MAX_F32)
	end,
	V2i16 = function(value: unknown)
		return typeof(value) == "Vector2int16"
	end,
	V3f16 = function(value: unknown)
		return checkVector3(value, MAX_F16)
	end,
	V3f24 = function(value: unknown)
		return checkVector3(value, MAX_F24)
	end,
	V3f32 = function(value: unknown)
		return checkVector3(value, MAX_F32)
	end,
	V3i16 = function(value: unknown)
		return typeof(value) == "Vector3int16"
	end,
	Transformer = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		return pcall(function()
			local encoded = datatype.enc(value)
			assert(evaluator.evaluators[datatype.Form.Eval](encoded, datatype.Form))
		end)
	end,
	lit = function(value: unknown, datatype: types.DatatypeInterface<unknown>)
		return datatype.val and value == datatype.val
	end,
} :: evaluators

return evaluator
