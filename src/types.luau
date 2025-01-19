-- Shared types within pack

export type WriteFlags = {}

export type Packet<T> = {
	Read: (self: Packet<T>, buff: buffer) -> T,
	Write: (self: Packet<T>, data: T, flags: WriteFlags?) -> buffer,
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

	Destroy: (self: Reader) -> (),

	_buffer: buffer,
}

export type Writer = {
	alloc: (self: Writer, number) -> (),

	u8: (self: Writer, value: number) -> (),
	u16: (self: Writer, value: number) -> (),
	u32: (self: Writer, value: number) -> (),
	i8: (self: Writer, value: number) -> (),
	i16: (self: Writer, value: number) -> (),
	i32: (self: Writer, value: number) -> (),
	f32: (self: Writer, value: number) -> (),
	f64: (self: Writer, value: number) -> (),
	string: (self: Writer, value: string, count: number?) -> number, -- Returns the string's length in bytes

	Finalize: (self: Writer) -> buffer,
	Destroy: (self: Writer) -> (),
}

export type DatatypeInterface<T> = {
	Read: (Reader) -> T,
	Write: (writer: Writer, value: T, flags: any?) -> (),
}

--[=[
		@class Datatypes

		Description TODO
]=]

return nil
