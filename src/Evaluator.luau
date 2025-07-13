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
	Array = function(value: any, datatype: types.DatatypeInterface<any>)
		if type(value) == "table" then
			local expectedIndex = 1
			for i, v in value do
				if i ~= expectedIndex then return false end
				if not evaluator.evaluators[datatype.Of.Eval](v, datatype.Of) then return false end
				expectedIndex += 1
			end
			return true
		end
		return false
	end,
	BitField = function(value: any)
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
	bool = function(value: any)
		return type(value) == "boolean"
	end,
	BrickColor = function(value: any)
		return typeof(value) == "BrickColor"
	end,
	buffer8 = function(value: any)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 8 then return true end
		end
		return false
	end,
	buffer16 = function(value: any)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 16 then return true end
		end
		return false
	end,
	buffer24 = function(value: any)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 24 then return true end
		end
		return false
	end,
	buffer32 = function(value: any)
		if type(value) == "buffer" then
			if buffer.len(value) < 2 ^ 32 then return true end
		end
		return false
	end,
	buffer = function(value: any, datatype: types.DatatypeInterface<any>)
		if type(value) == "buffer" then
			if buffer.len(value) < datatype.len then return true end
		end
		return false
	end,
	CFrame = function(value: any)
		return typeof(value) == "CFrame"
	end,
	Color3 = function(value: any)
		if typeof(value) == "Color3" then
			if value.R < 256 and value.G < 256 and value.B < 256 then return true end
		end
		return false
	end,
	Color3Raw = function(value: any)
		return typeof(value) == "Color3"
	end,
	DateTime = function(value: any)
		return typeof(value) == "DateTime"
	end,
	Dict = function(value: any, datatype: types.DatatypeInterface<any>)
		if typeof(value) ~= "table" then return false end
		-- First check number of keys
		local vLen, fLen = 0, 0
		for _ in value do
			vLen += 1
		end
		for _ in datatype.format do
			fLen += 1
		end
		if vLen ~= fLen then return false end

		for k, v in value do
			if not datatype.format[k] then return false end
			if not evaluator.evaluators[datatype.format[k].Eval](v, datatype.format[k]) then return false end
		end
		return true
	end,
	Enum = function(value: any, datatype: types.DatatypeInterface<any>)
		-- TODO: Look for a faster way to do this
		for _, v in (datatype.Item :: Enum):GetEnumItems() do
			if value == v then return true end
		end
		return false
	end,
	f16 = function(value: any)
		if type(value) ~= "number" then return false end
		return CanRepresent(value, MAX_F16, 10)
	end,
	f24 = function(value: any)
		if type(value) ~= "number" then return false end
		return CanRepresent(value, MAX_F24, 16)
	end,
	f32 = function(value: any)
		if type(value) ~= "number" then return false end
		return CanRepresent(value, MAX_F32, 23)
	end,
	f64 = function(value: any)
		return type(value) == "number"
	end,
	Inst_Ref = function(value: any)
		return typeof(value) == "Instance"
	end,
	i8 = function(value: any)
		return type(value) == "number" and value >= -(2 ^ 8) and value <= (2 ^ 8 - 1) and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	i16 = function(value: any)
		return type(value) == "number" and value >= -(2 ^ 16) and value <= (2 ^ 16 - 1) and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	i32 = function(value: any)
		return type(value) == "number" and value >= -(2 ^ 32) and value <= (2 ^ 32 - 1) and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	Map = function(value: any, datatype: types.DatatypeInterface<any>)
		if type(value) ~= "table" then return false end
		for k, v in value do
			if not evaluator.evaluators[datatype.Key.Eval](k, datatype.Key) then return false end
			if not evaluator.evaluators[datatype.Val.Eval](v, datatype.Val) then return false end
		end
		return true
	end,
	["nil"] = function(value: any)
		return value == nil
	end,
	nullable = function(value: any, datatype: types.DatatypeInterface<any>)
		return value == nil or evaluator.evaluators[datatype.dt.Eval](value, datatype.dt)
	end,
	object = function(value: any, datatype: types.DatatypeInterface<any>)
		if type(value) ~= "table" then return false end
		if getmetatable(value :: any) ~= datatype.mt then return false end
		return evaluator.evaluators[datatype.cData.Eval](value, datatype.cData)
	end,
	R3 = function(value: any)
		return typeof(value) == "Region3"
	end,
	R3i16 = function(value: any)
		return typeof(value) == "Region3int16"
	end,
	SDict = function(_value: any, datatype: types.DatatypeInterface<any>)
		-- must be a table
		if typeof(_value) ~= "table" then return false end
		local value: { [any]: any } = _value

		local required: { [any]: any } = datatype.format or {}
		local optional = datatype.optFormat
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
			if v == nil then return false end
			if not evaluator.evaluators[def.Eval](v, def) then return false end
		end

		for key, v in value do
			if required[key] then
				-- already validated
				continue
			end

			local def = optional[key]
			if def then
				if v then
					if not evaluator.evaluators[(def :: any).Eval](v, def :: any) then return false end
				end
			else
				return false
			end
		end

		return true
	end,
	s8 = function(value: any)
		if type(value) ~= "string" then return false end
		return buffer.len(buffer.fromstring(value)) < 2 ^ 8
	end,
	s16 = function(value: any)
		if type(value) ~= "string" then return false end
		return buffer.len(buffer.fromstring(value)) < 2 ^ 16
	end,
	s24 = function(value: any)
		if type(value) ~= "string" then return false end
		return buffer.len(buffer.fromstring(value)) < 2 ^ 24
	end,
	s32 = function(value: any)
		return type(value) == "string"
	end,
	string = function(value: any, datatype: types.DatatypeInterface<any>)
		if type(value) ~= "string" then return false end
		return buffer.len(buffer.fromstring(value)) == datatype.len
	end,
	UD = function(value: any)
		return typeof(value) == "UDim"
	end,
	UD2 = function(value: any)
		return typeof(value) == "UDim2"
	end,
	u8 = function(value: any)
		return type(value) == "number" and value >= 0 and value < 2 ^ 8 and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	u16 = function(value: any)
		return type(value) == "number" and value >= 0 and value < 2 ^ 16 and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	u32 = function(value: any)
		return type(value) == "number" and value >= 0 and value < 2 ^ 32 and fuzzyEq(value, math.floor(value), 1e-9)
	end,
	V2f16 = function(value: any)
		return checkVector2(value, MAX_F16)
	end,
	V2f24 = function(value: any)
		return checkVector2(value, MAX_F24)
	end,
	V2f32 = function(value: any)
		return checkVector2(value, MAX_F32)
	end,
	V3f16 = function(value: any)
		return checkVector3(value, MAX_F16)
	end,
	V3f24 = function(value: any)
		return checkVector3(value, MAX_F24)
	end,
	V3f32 = function(value: any)
		return checkVector3(value, MAX_F32)
	end,
	Transformer = function(value: any, datatype: types.DatatypeInterface<any>)
		return pcall(function()
			local encoded = datatype.enc(value)
			assert(evaluator.evaluators[datatype.Form.Eval](encoded, datatype.Form))
		end)
	end,
	lit = function(value: any, datatype: types.DatatypeInterface<any>)
		return value == datatype.val
	end,
} :: evaluators

return evaluator
