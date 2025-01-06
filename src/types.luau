-- Shared types within pack

export type WriteFlags = {}

export type Packet<T> = {
	Read: (buff: buffer) -> T,
	Write: (data: T, flags: WriteFlags?) -> buffer,
}

export type Writer = {
	Alloc: (self: Writer, number) -> (),

	u8: (self: Writer, value: number) -> (),
	u16: (self: Writer, value: number) -> (),
	u32: (self: Writer, value: number) -> (),
	i8: (self: Writer, value: number) -> (),
	i16: (self: Writer, value: number) -> (),
	i32: (self: Writer, value: number) -> (),
	f32: (self: Writer, value: number) -> (),
	f64: (self: Writer, value: number) -> (),
	string: (self: Writer, value: string, count: number?) -> (),

	Finalize: (self: Writer) -> buffer,
	Destroy: (self: Writer) -> (),
}

export type Reader = {
	Cursor: number,

	MoveCursor: (number) -> (), -- Force move the cursor, but try and rely on the automatic cursor pushing

	_buffer: buffer,
}

export type DatatypeInterface<T> = {
	Read: (Reader) -> T,
	Write: (writer: Writer, value: T, flags: any) -> (),
}

return nil
