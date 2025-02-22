-- Shared types within pack

export type Schema<T, U...> = {
	Read: (self: Schema<T, U...>, buff: buffer) -> (T, U...),
	Write: (self: Schema<T, U...>, T, U...) -> buffer,
}

export type Reader = {
	Cursor: number,

	read moveCursor: (self: Reader, number) -> (), -- Force move the cursor, but try and rely on the automatic cursor pushing
	read u8: (self: Reader) -> number,
	read u16: (self: Reader) -> number,
	read u32: (self: Reader) -> number,
	read i8: (self: Reader) -> number,
	read i16: (self: Reader) -> number,
	read i32: (self: Reader) -> number,
	read nBitUint: (self: Reader, n: number, bitOffset: number) -> number,
	read nBitInt: (self: Reader, n: number, bitOffset: number) -> number,
	read f32: (self: Reader) -> number,
	read f64: (self: Reader) -> number,
	read string: (self: Reader, count: number?) -> string,

	_buffer: buffer,
}

export type Writer = {
	read alloc: (self: Writer, number) -> (),
	read moveCursor: (self: Writer, delta: number) -> (),

	read u8: (self: Writer, value: number) -> (),
	read u16: (self: Writer, value: number) -> (),
	read u32: (self: Writer, value: number) -> (),
	read i8: (self: Writer, value: number) -> (),
	read i16: (self: Writer, value: number) -> (),
	read i32: (self: Writer, value: number) -> (),
	read nBitUint: (self: Writer, value: number, n: number, bitOffset: number) -> (),
	read nBitInt: (self: Writer, value: number, n: number, bitOffset: number) -> (),
	read f32: (self: Writer, value: number) -> (),
	read f64: (self: Writer, value: number) -> (),
	read string: (self: Writer, value: string, count: number?) -> (number, () -> ()), -- Returns the string's length in bytes and a function to actually write the string

	read Finalize: (self: Writer) -> buffer,
}

export type DatatypeInterface<T> = {
	read Eval: string?,
	read Read: (Reader) -> T,
	read Write: (writer: Writer, value: T) -> (),
	[string]: any,
}

export type Datatypes = {
	read uint8: number,
	read UByte: number,
	read uint16: number,
	read UShort: number,
	read uint32: number,
	read UInt: number,

	read int8: number,
	read Byte: number,
	read int16: number,
	read Short: number,
	read int32: number,
	read Int: number,

	read float32: number,
	read Float: number,
	read float64: number,
	read double: number,

	read boolean: boolean,
	read BitField: (length: number) -> { boolean },

	read string8: string,
	read string16: string,
	read string32: string,
	read string_fixed: (len: number) -> string,

	read buffer8: buffer,
	read buffer16: buffer,
	read buffer32: buffer,
	read buffer_fixed: (len: number) -> buffer,

	read Color3: Color3,
	read Color3float32: Color3,
	read BrickColor: BrickColor,

	read CFrame: CFrame,
	read Vector3: vector & Vector3,
	read Vector3int16: vector & Vector3,
	read Vector2: Vector2,
	read Vector2int16: Vector2,
	read Region3: Region3,
	read Region3int16: Region3int16,
	read UDim: Udim,
	read UDim2: UDim2,

	read DateTime: DateTime,
	read EnumItem: EnumItem,
	read Instance: Instance,

	read custom: <T>(read: (Reader) -> T, write: (Writer, T) -> ()) -> T,
	read object: <T, U>(metatable: T, classData: U) -> typeof(setmetatable({} :: U, {} :: T)),

	read Array: <T>(type: T) -> { T },
	read Dictionary: <T>(format: T) -> T,
	read Map: <K, V>(keyType: K, valueType: V) -> { [K]: V },

	read null: nil,
	read nullable: <T>(type: T) -> T?,
}

export type Pack = {
	-- Schema constructors
	-- A schema is a tuple, but only the first argument can be properly typed
	-- This is a limitation of Luau, as there is no higher-order polymorphism
	-- Meaning we cannot pass multiple generics to the lower order read/write methods
	Define: <T, U...>(self: Pack, T, U...) -> Schema<T, U...>,
} & Datatypes

return nil
