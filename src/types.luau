--!strict
--# selene:allow(undefined_variable)

local SharedTableRegistry = game:GetService("SharedTableRegistry")

-- Shared types within pack

export type Schema<T, U...> = {
	Read: (self: Schema<T, U...>, buff: buffer, refs: refs?) -> (T, U...),
	Write: (self: Schema<T, U...>, T, U...) -> (buffer, refs?),
}

export type ReaderData = {
	refs: refs,

	-- Main buffer
	Cursor: number,
	_buffer: buffer,

	-- Bit buffer
	BitCursor: number,
}

export type Reader = {
	read moveCursor: (self: ReaderData, number) -> (), -- Force move the cursor, but try and rely on the automatic cursor pushing
	read u8: (self: ReaderData) -> number,
	read u16: (self: ReaderData) -> number,
	read u32: (self: ReaderData) -> number,
	read i8: (self: ReaderData) -> number,
	read i16: (self: ReaderData) -> number,
	read i32: (self: ReaderData) -> number,
	read nBitUint: (self: ReaderData, n: number, bitOffset: number) -> number,
	read nBitInt: (self: ReaderData, n: number, bitOffset: number) -> number,
	read nBitFloat: (self: ReaderData, n: number, m: number, bitOffset: number) -> number,
	read f32: (self: ReaderData) -> number,
	read f64: (self: ReaderData) -> number,
	read string: (self: ReaderData, count: number?) -> string,

	read new: (packet: buffer) -> ReaderData,
}

export type WriterData = {
	refs: refs,
	nRefs: number,

	-- Main buffer
	_len: number,
	_queue: { vector | { any } },

	-- Bit buffer
	_bitLen: number,
	_bitQueue: { vector },
}

export type Writer = {
	read alloc: (self: WriterData, number) -> (),
	read moveCursor: (self: WriterData, delta: number) -> (),

	read u8: (self: WriterData, value: number) -> (),
	read u16: (self: WriterData, value: number) -> (),
	read u32: (self: WriterData, value: number) -> (),
	read i8: (self: WriterData, value: number) -> (),
	read i16: (self: WriterData, value: number) -> (),
	read i32: (self: WriterData, value: number) -> (),
	read nBitUint: (self: WriterData, value: number, n: number, bitOffset: number) -> (),
	read nBitInt: (self: WriterData, value: number, n: number, bitOffset: number) -> (),
	read nBitFloat: (self: WriterData, value: number, n: number, m: number, bitOffset: number) -> (),
	read f32: (self: WriterData, value: number) -> (),
	read f64: (self: WriterData, value: number) -> (),
	read string: (self: WriterData, value: string, count: number?) -> (number, () -> ()), -- Returns the string's length in bytes and a function to actually write the string
	read addRef: (self: WriterData, ref: any) -> (),

	read Finalize: (self: WriterData) -> buffer,

	read new: () -> WriterData,
}

--[=[
	@class Datatype
	:::note
	This is the Internal documentation for writing custom datatypes. If you were looking for a list of all datatypes, that can be found [**here**](../docs/Datatypes/Primitives)
	:::

	Internally, all datatypes follow the DatatypeInterface format.

	You can have static datatypes, which require no arguments passed in (most primitives).
	```lua
	-- float64.luau

	local Pack = require(path.to.pack)
	local Reader = Pack.Reader
	local Writer = Pack.Writer

	-- You should freeze the DatatypeInterface table
	local datatype = table.freeze({
		Eval = "f64",
		Read = function(reader: Pack.ReaderData): number
			return Reader.f64(reader)
		end,
		Write = function(writer: Pack.WriterData, value: number)
			Writer.alloc(writer, 8)
			Writer.f64(writer, value)
		end,
	}) :: Pack.DatatypeInterface<number>
	
	-- For type inference when writing packets, we dont use the 
	-- DatatypeInterface type when returning our datatype module.
	-- Instead we want to annoate it as the basic type, in this case number.
	return (datatype :: any) :: number
	```

	You can also have dynamic datatypes which require arguments passed in (structural datatypes).
	```lua
	-- Array.luau

	local Pack = require(path.to.pack)
	local Reader = Pack.Reader
	local Writer = Pack.Writer
	
	-- We return a function where we provide the datatype 
	-- to use for values and return an array datatype for that
	return function<T>(valueType: Pack.DatatypeInterface<T>): Pack.DatatypeInterface<{ T }>
		local read, write = valueType.Read, valueType.Write

		-- We also freeze the dynamic datatype tables
		return table.freeze({
			Eval = "Array",
			Of = valueType.Eval, -- Example of adding extra data for the evaluator
			Read = function(reader: Pack.ReaderData): { T }
				local len = Reader.u16(reader)
				local array = table.create(len) :: { T }

				for i = 1, len do
					array[i] = read(reader)
				end

				return array
			end,
			Write = function(writer: Pack.WriterData, value: { T })
				local len = #value
				Writer.alloc(writer, 2)
				Writer.u16(writer, len)

				for i = 1, len do
					write(writer, value[i])
				end
			end,
		}) :: Pack.DatatypeInterface<{ T }>
	-- We also want to annotate a basic type for dynamic datatypes for type inference in Schemas
	end :: <T>(T) -> { T }
	```

	When making your own datatypes, you only have to worry about Eval if you want to use that datatype inside Union
]=]

--[=[
	@type DatatypeInterface<T> {Eval: string?, Read: (ReaderData) -> T, Write: (writer: WriterData, value: T) -> ()}
	@within Datatype
	Eval is a string indicating which evaluator to use for this value if applicable. Extra info can be added regarding this for advanced datatypes.  
	Read is a function that is passed a ReaderData instance and expected to read the ReaderData and return whatever was passed into Write.
	Write is a function that is passed a WriterData instance and a value and is expected to write the value into WriterData.
]=]
export type DatatypeInterface<T> = {
	read Eval: string?,
	read Read: (ReaderData) -> T,
	read Write: (writer: WriterData, value: T) -> (),
	[string]: any,
}

export type refs = { any }

type Vector = vector & Vector3
export type Datatypes = {
	UInt8: number,
	UByte: number,
	UInt16: number,
	UShort: number,
	UInt32: number,
	UInt: number,
	UInt64: number,
	ULong: number,

	Int8: number,
	Byte: number,
	Int16: number,
	Short: number,
	Int32: number,
	Int: number,
	Int64: number,
	Long: number,

	Float16: number,
	Float24: number,
	Float32: number,
	Float: number,
	Float64: number,
	Double: number,

	Boolean: boolean,
	BitField: (length: number) -> { boolean },

	String8: string,
	String16: string,
	String24: string,
	String32: string,
	StringFixed: (len: number) -> string,

	Buffer8: buffer,
	Buffer16: buffer,
	Buffer24: buffer,
	Buffer32: buffer,
	BufferFixed: (len: number) -> buffer,

	Color3: Color3,
	Color3float32: Color3,
	BrickColor: BrickColor,

	CFrame: CFrame,
	Vector3: Vector,
	Vector3float32: Vector,
	Vector3float64: Vector,
	Vector3float24: Vector,
	Vector3float16: Vector,
	Vector3int16: Vector,
	Vector2: Vector2,
	Vector2float32: Vector2,
	Vector2float64: Vector2,
	Vector2float24: Vector2,
	Vector2float16: Vector2,
	Vector2int16: Vector2,
	Region3: Region3,
	Region3int16: Region3int16,
	UDim: UDim,
	UDim2: UDim2,

	DateTime: DateTime,
	Instance: Instance,
	EnumItem: (Enum) -> any,

	Custom: <T>(read: (Reader) -> T, write: (Writer, T) -> ()) -> T,
	Object: <T, U>(metatable: T, classData: U) -> setmetatable<U, T>,
	Transformer: <T, U>(format: U, encode: ((T) -> U)?, decode: ((U) -> T)?) -> T,

	Array: <T>(type: T) -> { T },
	Dictionary: <T>(format: T) -> T,
	SparseDictionary: <T, U>(optionalFormat: T, requireFormat: U?) -> nullableKeys<T> & U,
	Map: <K, V>(keyType: K, valueType: V) -> { [K]: V },

	Null: nil,
	Nullable: <T>(type: T) -> T?,
	-- If possible make this a type function to union all members of a type pack
	Union: <T0, T1, T2, T3, T4, T5, T6, T7>(v0: T0, v1: T1, v2: T2?, v3: T3?, v4: T4?, v5: T5?, v6: T6?, v7: T7?) -> T1 | T2 | T3 | T4 | T5 | T6 | T7,
	Any: any,
}

export type Pack = {
	-- Schema constructors
	-- A schema is a tuple, but only the first argument can be properly typed
	-- This is a limitation of Luau, as there is no higher-order polymorphism
	-- Meaning we cannot pass multiple generics to the lower order read/write methods
	Define: <T, U...>(self: Pack, T, U...) -> Schema<T, U...>,

	Reader: Reader,
	Writer: Writer,
} & Datatypes

-- Makes every property of a table type nullable (i.e. T[K] -> T[K] | nil)
type function nullableKeys(ty: type)
	-- ensure we only operate on table types
	if not ty:is("table") then error("nullableKeys can only be called on table types") end

	-- create a fresh table-type to populate
	local newTable = types.newtable()

	-- iterate over each key (singleton string type) in the original table
	for prop in ty:properties() do
		-- get the original property’s read type
		local origType = ty:readproperty(prop)
		if origType then
			-- union it with nil
			local nilType = types.singleton(nil)
			local unionType = types.unionof(origType, nilType)
			-- set both read+write to the new nullable union
			newTable:setproperty(prop, unionType)
		end
	end

	return newTable
end

local config = SharedTableRegistry:GetSharedTable("PACK_CONFIG")

local packConfig = {}

packConfig.DEBUG = config.__DEBUG__

return packConfig
