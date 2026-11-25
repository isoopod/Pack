--!native
--!optimize 2

const Array = require(script.Parent.Array)
const Boolean = require(script.Parent.Boolean)
const Buffer16 = require(script.Parent.Buffer16)
const Buffer24 = require(script.Parent.Buffer24)
const Buffer32 = require(script.Parent.Buffer32)
const Buffer8 = require(script.Parent.Buffer8)
const CFrame = require(script.Parent.CFrame)
const Color3 = require(script.Parent.Color3)
const Color3float32 = require(script.Parent.Color3float32)
const DateTime = require(script.Parent.DateTime)
const Float64 = require(script.Parent.Float64)
const Instance = require(script.Parent.Instance)
const Int16 = require(script.Parent.Int16)
const Int32 = require(script.Parent.Int32)
const Int8 = require(script.Parent.Int8)
const Map = require(script.Parent.Map)
const Null = require(script.Parent.Null)
const Region3 = require(script.Parent.Region3)
const Region3int16 = require(script.Parent.Region3int16)
const String16 = require(script.Parent.String16)
const String24 = require(script.Parent.String24)
const String32 = require(script.Parent.String32)
const String8 = require(script.Parent.String8)
const UDim = require(script.Parent.UDim)
const UDim2 = require(script.Parent.UDim2)
const UInt16 = require(script.Parent.UInt16)
const UInt32 = require(script.Parent.UInt32)
const UInt8 = require(script.Parent.UInt8)
const Union = require(script.Parent.Union)
const Vector2 = require(script.Parent.Vector2)
const Vector2int16 = require(script.Parent.Vector2int16)
const Vector3 = require(script.Parent.Vector3)
const Vector3int16 = require(script.Parent.Vector3int16)
const types = require(script.Parent.Parent.types)

const datatype = {}

local any: types.DatatypeInterface<any>? -- Deferred definition

-- Lazy initialisation
const function getAny(): types.DatatypeInterface<any>
	if any == nil then
		-- These depend on datatype being fully defined
		const tbl = Map(datatype, datatype)
		const array = Array(datatype, UInt32)

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
			Vector3(),
			Vector2(),
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
