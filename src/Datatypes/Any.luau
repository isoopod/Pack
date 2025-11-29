--!native
--!optimize 2

local Array = require(script.Parent.Array)
local Boolean = require(script.Parent.Boolean)
local Buffer16 = require(script.Parent.Buffer16)
local Buffer24 = require(script.Parent.Buffer24)
local Buffer32 = require(script.Parent.Buffer32)
local Buffer8 = require(script.Parent.Buffer8)
local CFrame = require(script.Parent.CFrame)
local Color3 = require(script.Parent.Color3)
local Color3float32 = require(script.Parent.Color3float32)
local DateTime = require(script.Parent.DateTime)
local Float64 = require(script.Parent.Float64)
local Instance = require(script.Parent.Instance)
local Int16 = require(script.Parent.Int16)
local Int32 = require(script.Parent.Int32)
local Int8 = require(script.Parent.Int8)
local Map = require(script.Parent.Map)
local Null = require(script.Parent.Null)
local Region3 = require(script.Parent.Region3)
local Region3int16 = require(script.Parent.Region3int16)
local String16 = require(script.Parent.String16)
local String24 = require(script.Parent.String24)
local String32 = require(script.Parent.String32)
local String8 = require(script.Parent.String8)
local UDim = require(script.Parent.UDim)
local UDim2 = require(script.Parent.UDim2)
local UInt16 = require(script.Parent.UInt16)
local UInt32 = require(script.Parent.UInt32)
local UInt8 = require(script.Parent.UInt8)
local Union = require(script.Parent.Union)
local Vector2 = require(script.Parent.Vector2)
local Vector2int16 = require(script.Parent.Vector2int16)
local Vector3 = require(script.Parent.Vector3)
local Vector3int16 = require(script.Parent.Vector3int16)
local types = require(script.Parent.Parent.types)

local datatype = {}

local any: types.DatatypeInterface<any>? -- Deferred definition

-- Lazy initialisation
local function getAny(): types.DatatypeInterface<any>
	if any == nil then
		-- These depend on datatype being fully defined
		local tbl = Map(datatype, datatype)
		local array = Array(datatype, UInt32)

		any = Union(
			UInt8,
			UInt16,
			UInt32,
			Int8,
			Int16,
			Int32,
			Float64,
			Boolean,
			String8,
			String16,
			String24,
			String32,
			Vector3,
			Vector2,
			CFrame,
			Instance,
			Null,
			Color3,
			Color3float32,
			Region3,
			UDim2,
			UDim,
			Buffer8,
			Buffer16,
			Buffer24,
			Buffer32,
			DateTime,
			Vector3int16,
			Vector2int16,
			Region3int16,
			array,
			tbl
		)
	end
	return any :: any
end

datatype.Eval = "Any"
datatype.BitLen = 5
datatype.Read = function(reader: types.ReaderData): any
	return getAny().Read(reader)
end
datatype.Write = function(writer: types.WriterData, value: any)
	getAny().Write(writer, value)
end

return table.freeze(datatype)
