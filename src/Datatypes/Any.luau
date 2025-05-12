--!strict
--!native
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Evaluator = require(ReplicatedStorage.Pack.Evaluator)
local Map = require(script.Parent.Map)
local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

-- Basic search for primitive datatypes
local searchOrder = {
	"u8",
	"u16",
	"u32",
	"i8",
	"i16",
	"i32",
	"f16",
	"f24",
	"f32",
	"f64",
	"bool",
	"s8",
	"s16",
	"s24",
	"s32",
	"V3f32",
	"V3f64",
	"V2f32",
	"V2f64",
	"CFrame",
	"Instance",
	"nil",
	"Color3",
	"Color3Raw",
	"R3",
	"UD",
	"UD2",
	"buffer8",
	"buffer16",
	"buffer24",
	"buffer32",
	"DateTime",
	"V3i16",
	"V2i16",
	"R3i16",
}

local idToEval = {}
for k, v in Evaluator.evalToId do
	idToEval[v] = k
end

local datatype = {}

local tbl = Map(datatype, datatype)

datatype.Eval = "Any"
datatype.Read = function(reader: types.ReaderData): number
	-- TODO
end
datatype.Write = function(writer: types.WriterData, value: number)
	-- Attempt to find a valid representation for value
	for _, v in searchOrder do
		if Evaluator.evaluators[v](value, nil :: any) then
			Writer.alloc(writer, 1)
			Writer.u8(writer, Evaluator.evalToId[v])
			require(Evaluator.indexToDatatype[Evaluator.evalToId[v]]).Write(writer, value)
			return
		end
	end

	-- Handle other cases
	if type(value) == "table" then
		-- For now, treat tables as map [any]: any
		Writer.u8(writer, Evaluator.evalToId[tbl.Eval :: string])
		tbl.Write(writer, value)
	end
end

return table.freeze(datatype)
