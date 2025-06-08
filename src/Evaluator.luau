--!strict
--!optimize 2
--!native

local types = require(script.Parent.types)

type evaluators = {
	[string]: (value: any, datatype: types.DatatypeInterface<any>) -> boolean,
}

-- HELPERS --

-- precompute max normals for each floting point format
local MAX_F16 = (2 - 2 ^ -10) * 2 ^ 15
local MAX_F24 = (2 - 2 ^ -16) * 2 ^ 63
local MAX_F32 = (2 - 2 ^ -23) * 2 ^ 127

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

local datatypes = script.Parent.Datatypes
evaluator.indexToDatatype = {
	-- Doesn't have to be alphabetical
	-- Custom datatypes can be inserted as well
	-- Gaps are allowed
	-- Min 0
	-- Max 255
	[0] = datatypes.Array,
	[1] = datatypes.BitField,
	[2] = datatypes.Boolean,
	[3] = datatypes.BrickColor,
	[4] = datatypes.Buffer8,
	[5] = datatypes.Buffer16,
	[6] = datatypes.Buffer24,
	[7] = datatypes.Buffer32,
	[8] = datatypes.BufferFixed,
	[9] = datatypes.CFrame,
	[10] = datatypes.Color3,
	[11] = datatypes.Color3float32,
	[12] = datatypes.DateTime,
	[13] = datatypes.Dictionary,
	[14] = datatypes.EnumItem,
	[15] = datatypes.Float16,
	[16] = datatypes.Float24,
	[17] = datatypes.Float32,
	[18] = datatypes.Float64,
	[19] = datatypes.Instance,
	[20] = datatypes.Int8,
	[21] = datatypes.Int16,
	[22] = datatypes.Int32,
	[23] = datatypes.Map,
	[24] = datatypes.Null,
	[25] = datatypes.Nullable,
	[26] = datatypes.Object,
	[27] = datatypes.Region3,
	[28] = datatypes.Region3int16,
	[29] = datatypes.SparseDictionary,
	[30] = datatypes.String8,
	[31] = datatypes.String16,
	[32] = datatypes.String24,
	[33] = datatypes.String32,
	[34] = datatypes.StringFixed,
	[35] = datatypes.UDim,
	[36] = datatypes.UDim2,
	[37] = datatypes.UInt8,
	[38] = datatypes.UInt16,
	[39] = datatypes.UInt32,
	[40] = datatypes.Vector2float16,
	[41] = datatypes.Vector2float24,
	[42] = datatypes.Vector2float32,
	[43] = datatypes.Vector2float64,
	[44] = datatypes.Vector2int16,
	[45] = datatypes.Vector3float16,
	[46] = datatypes.Vector3float24,
	[47] = datatypes.Vector3float32,
	[48] = datatypes.Vector3float64,
	[49] = datatypes.Vector3int16,
	[50] = datatypes.Transformer,
} :: { [number]: ModuleScript }

evaluator.evalToId = {
	Array = 0,
	BitField = 1,
	bool = 2,
	BrickColor = 3,
	buffer8 = 4,
	buffer16 = 5,
	buffer24 = 6,
	buffer32 = 7,
	buffer = 8, -- BufferFixed -> Eval = "buffer"
	CFrame = 9,
	Color3 = 10,
	Color3Raw = 11, -- Color3float32 -> Eval = "Color3Raw"
	DateTime = 12,
	Dict = 13, -- Dictionary -> Eval = "Dict"
	Enum = 14, -- EnumItem -> Eval = "Enum"
	f16 = 15,
	f24 = 16,
	f32 = 17,
	f64 = 18,
	Inst_Ref = 19,
	i8 = 20,
	i16 = 21,
	i32 = 22,
	Map = 23,
	["nil"] = 24,
	nullable = 25,
	object = 26,
	R3 = 27, -- Region3 -> Eval = "R3"
	R3i16 = 28, -- Region3Int16 -> Eval = "R3i16"
	SDict = 29,
	s8 = 30,
	s16 = 31,
	s24 = 32,
	s32 = 33,
	string = 34, -- StringFixed -> Eval = "string"
	UD = 35,
	UD2 = 36,
	u8 = 37,
	u16 = 38,
	u32 = 39,
	V2f16 = 40,
	V2f24 = 41,
	V2f32 = 42,
	V2f64 = 43,
	V2int16 = 44, -- Vector2int16 -> Eval = "V2int16"
	V3f16 = 45,
	V3f24 = 46,
	V3f32 = 47,
	V3f64 = 48,
	V3int16 = 49, -- Vector3int16 -> Eval = "V3int16"
	Transformer = 50,
}

function evaluator.addEvaluator(Eval: string, id: number, module: ModuleScript, func: (value: any, datatype: types.DatatypeInterface<any>) -> boolean)
	evaluator.indexToDatatype[id] = module
	evaluator.evalToId[Eval] = id
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
		return value >= -MAX_F16 and value <= MAX_F16
	end,
	f24 = function(value: any)
		if type(value) ~= "number" then return false end
		return value >= -MAX_F24 and value <= MAX_F24
	end,
	f32 = function(value: any)
		if type(value) ~= "number" then return false end
		return value >= -MAX_F32 and value <= MAX_F32
	end,
	f64 = function(value: any)
		return type(value) == "number"
	end,
	Inst_Ref = function(value: any)
		return typeof(value) == "Instance"
	end,
	i8 = function(value: any)
		return type(value) == "number" and value >= -(2 ^ 8) and value <= (2 ^ 8 - 1) and value % 1 == 0
	end,
	i16 = function(value: any)
		return type(value) == "number" and value >= -(2 ^ 16) and value <= (2 ^ 16 - 1) and value % 1 == 0
	end,
	i32 = function(value: any)
		return type(value) == "number" and value >= -(2 ^ 32) and value <= (2 ^ 32 - 1) and value % 1 == 0
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
					if not evaluator.evaluators[def.Eval](v, def :: any) then return false end
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
		return type(value) == "number" and value >= 0 and value < 2 ^ 8 and value % 1 == 0
	end,
	u16 = function(value: any)
		return type(value) == "number" and value >= 0 and value < 2 ^ 16 and value % 1 == 0
	end,
	u32 = function(value: any)
		return type(value) == "number" and value >= 0 and value < 2 ^ 32 and value % 1 == 0
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
	V2f64 = function(value: any)
		return typeof(value) == "Vector2"
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
	V3f64 = function(value: any)
		return type(value) == "vector"
	end,
	Transformer = function(value: any, datatype: types.DatatypeInterface<any>)
		return pcall(function()
			local encoded = datatype.enc(value)
			assert(evaluator.evaluators[datatype.Form.Eval](encoded, datatype.Form))
		end)
	end,
} :: evaluators

return evaluator
