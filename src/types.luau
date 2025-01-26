-- Shared types within pack

export type Schema<T> = {
	Read: (self: Schema<T>, buff: buffer) -> T,
	Write: (self: Schema<T>, data: T) -> buffer,
}

export type Reader = {
	Cursor: number,

	moveCursor: (number) -> (), -- Force move the cursor, but try and rely on the automatic cursor pushing
	u8: (self: Reader) -> number,
	u16: (self: Reader) -> number,
	u32: (self: Reader) -> number,
	i8: (self: Reader) -> number,
	i16: (self: Reader) -> number,
	i32: (self: Reader) -> number,
	f32: (self: Reader) -> number,
	f64: (self: Reader) -> number,
	string: (self: Reader, count: number?) -> string,

	_buffer: buffer,
}

export type Writer = {
	alloc: (self: Writer, number) -> (),
	moveCursor: (sefl: Writer, delta: number) -> (),

	u8: (self: Writer, value: number) -> (),
	u16: (self: Writer, value: number) -> (),
	u32: (self: Writer, value: number) -> (),
	i8: (self: Writer, value: number) -> (),
	i16: (self: Writer, value: number) -> (),
	i32: (self: Writer, value: number) -> (),
	f32: (self: Writer, value: number) -> (),
	f64: (self: Writer, value: number) -> (),
	string: (self: Writer, value: string, count: number?) -> (number, () -> ()), -- Returns the string's length in bytes and a function to actually write the string

	Finalize: (self: Writer) -> buffer,
}

export type DatatypeInterface<T> = {
	Read: (Reader) -> T,
	Write: (writer: Writer, value: T, flags: any?) -> (),
}

export type Pack = {
	-- Schema constructors
	Define: <T>(self: Pack, schema: T) -> Schema<T>,

	-- [Datatypes] --
	uint8: number,
	UByte: number,
	uint16: number,
	UShort: number,
	uint32: number,
	UInt: number,

	int8: number,
	Byte: number,
	int16: number,
	Short: number,
	int32: number,
	Int: number,

	float32: number,
	Float: number,
	float64: number,
	double: number,

	boolean: boolean,
	BitField: (length: number) -> { boolean },

	string8: string,
	string16: string,
	string32: string,
	string_fixed: (len: number) -> string,

	buffer8: buffer,
	buffer16: buffer,
	buffer32: buffer,
	buffer_fixed: (len: number) -> buffer,

	Color3: Color3,
	BrickColor: BrickColor,

	CFrame: CFrame,
	Vector3: vector & Vector3,
	Vector2: Vector2,

	Instance: Instance,

	custom: <T>(read: (Reader) -> T, write: (Writer, T) -> ()) -> T,

	Array: <T>(type: T) -> { T },
	Dictionary: <T>(format: T) -> T,
	Map: <K, V>(keyType: K, valueType: V) -> { [K]: V },

	nullable: <T>(type: T) -> T?,
}

return nil
