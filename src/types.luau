-- Shared types within pack

export type Schema<T, U...> = {
	Read: (self: Schema<T, U...>, buff: buffer, refs: refs?) -> (T, U...),
	Write: (self: Schema<T, U...>, T, U...) -> (buffer, refs?),
}

export type ReaderData = {
	Cursor: number,
	refs: refs,
	_buffer: buffer,
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
	read f32: (self: ReaderData) -> number,
	read f64: (self: ReaderData) -> number,
	read string: (self: ReaderData, count: number?) -> string,

	read new: (packet: buffer) -> ReaderData,
}

export type WriterData = {
	refs: refs,
	_len: number,
	_queue: { { any } },
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
	read nBitInt: (self: WrWriterDataiWriterDatater, value: number, n: number, bitOffset: number) -> (),
	read f32: (self: WriterData, value: number) -> (),
	read f64: (self: WriterData, value: number) -> (),
	read string: (self: WriterData, value: string, count: number?) -> (number, () -> ()), -- Returns the string's length in bytes and a function to actually write the string

	read Finalize: (self: WriterData) -> buffer,

	read new: () -> WriterData,
}

export type DatatypeInterface<T> = {
	read Eval: string?,
	read Read: (ReaderData) -> T,
	read Write: (writer: WriterData, value: T) -> (),
	[string]: any,
}

export type refs = { any }

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
	read Double: number,

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

	Reader: Reader,
	Writer: Writer,
} & Datatypes

return nil
