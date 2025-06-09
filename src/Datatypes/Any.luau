--!strict
--!native
--!optimize 2

local Array = require(script.Parent.Array)
local Evaluator = require(script.Parent.Parent.Evaluator)
local Map = require(script.Parent.Map)
local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

-- Basic search for primitive datatypes
-- stylua: ignore
local searchOrder = {
	"u8", "u16", "u32", "i8", "i16", "i32", "f16", "f24", "f32", "f64", "bool", "s8", "s16", "s24", "s32", "V2f32", 
	"V2f64", "CFrame", "Instance", "nil", "Color3", "Color3Raw", "R3", "UD", "UD2", "buffer8", "buffer16", "buffer24", 
	"buffer32", "DateTime", "V3i16", "V2i16", "R3i16",
}

local idToEval = {}
for k, v in Evaluator.evalToId do
	idToEval[v] = k
end

local datatype = {}

-- Map of any -> any
local tbl = Map(datatype, datatype)

-- Array of any
local array = Array(datatype)

datatype.Eval = "Any"
datatype.Read = function(reader: types.ReaderData): any
	-- TODO
	local dtId = Reader.u8(reader)
	local s, dt = pcall(require, Evaluator.indexToDatatype[dtId])
	assert(s, "Get datatype from ID failed")
	return dt.Read(reader)
end
datatype.Write = function(writer: types.WriterData, value: any)
	-- Attempt to find a valid representation for value
	for _, v in searchOrder do
		if Evaluator.evaluators[v](value, nil :: any) then
			Writer.alloc(writer, 1)
			Writer.u8(writer, Evaluator.evalToId[v])
			local s, dt = pcall(require :: any, Evaluator.indexToDatatype[Evaluator.evalToId[v]])
			assert(s, "Get datatype from Eval failed")
			dt.Write(writer, value)
			return
		end
	end

	-- Handle other cases
	if type(value) == "table" then
		-- Check if the table is an array
		local expectedIndex: any = 1
		for i in value do
			if i ~= expectedIndex then
				expectedIndex = nil
				break
			end
			expectedIndex += 1
		end

		-- expectedIndex will be nil if not an array
		if expectedIndex then
			Writer.u8(writer, Evaluator.evalToId[array.Eval :: string])
			array.Write(writer, value :: any)
		else
			-- For now, treat tables as map [any]: any
			Writer.u8(writer, Evaluator.evalToId[tbl.Eval :: string])
			tbl.Write(writer, value :: any)
		end
	end
end

return table.freeze(datatype)
