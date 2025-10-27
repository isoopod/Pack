--!strict
--!native
--!optimize 2

-- Modules
local Reader = require(script.Reader)
local Writer = require(script.Writer)
local types = require(script.types)

local Pack = {}

-- Schema class
--[=[
	@class Schema

	A schema is needed to read and write a packet with a particular data structure.  
	Schemas are created through Pack:Define() through combinations of Pack datatypes.  

	Once created, a schema holds the Read and Write methods to serialize and deserialize data to and from packets (buffers).
]=]

--- @prop DisableReadProtection boolean?
--- @within Schema
--- If true, disables the read protection that checks if the entire packet was read.
--- This is not recommended unless you have a specific use case that requires it.

local Schema = {}

--[=[
	@method Write
	@within Schema
	@param ... any
	@return buffer -- This is your 'packet' that can be sent around or stored and later read by this schema.
	@return {any}? -- Table of refs for datatypes making use of this. Stock Pack does not use this and this is intended for Networking.
	Writes a packet (buffer) from the provided input, which should follow the structure of the schema.
]=]
function Schema.Write(self: _Schema, ...: any): (buffer, types.refs?)
	local refs = {}
	local writer = Writer.new(self._approxLen, self._approxBitLen)
	writer.refs = refs

	local input = { ... }
	for i = 1, self._args do
		self._writers[i](writer, input[i])
	end

	local packed = Writer.Finalize(writer)
	return packed, #refs > 0 and refs or nil
end

--[=[
	@method Read
	@within Schema
	@param packet buffer -- A packet created by this schema with the Write method.
	@param refs {any}? -- Optional table of refs for datatypes making use of this. Stock Pack does not use this and this is intended for Networking.
	@return (...any) -- This is a reconstruction of the input to the packet.
	Reads a packet (buffer) that was written with the same schema and outputs a reconstruction of the packet's input.
]=]
function Schema.Read(self: _Schema, packet: buffer, refs: types.refs?): ...any
	local reader = Reader.new(packet)
	reader.refs = refs :: any

	local tuple = table.create(self._args)
	for i = 1, self._args do
		tuple[i] = self._readers[i](reader)
	end

	if self.DisableReadProtection ~= true then
		local len = buffer.len(packet)
		local totalBytesRead = reader.Cursor + math.ceil((len * 8 - reader.BitCursor) / 8)
		if totalBytesRead ~= len then
			-- If the provided packet is longer than what we actually read, we know something has gone wrong
			-- This prevents most cases where unrelated data that somehow doesnt cause a parse error will be caught
			-- This can happen if a created packet gets read by the wrong schema, or an unrelated buffer is read in place of the packet
			error(`Packet len mismatch: Expected to read {len} bytes, only read {totalBytesRead}.`)
		end
	end

	return unpack(tuple)
end

--[=[
	@class Pack
	The singleton object from where Schemas are created and Datatypes can be accessed.
	
	The constructor for Schemas is accessed with `:` syntax  
	Datatypes are accessed with `.` syntax  
	All default datatypes can be found in [Docs/Datatypes](../docs/Datatypes/Primitives)
]=]

--[=[
	@method Define
	@within Pack
	@param ... Datatype -- See all datatypes in Docs/Datatypes
	@return Schema

	Defines a Schema from the provided datatypes.  
	This supports tuples, however due to luau limitations you will need to manually annotate the type.

	```lua title="tupleExample.luau"
	local Pack = require(path.to.pack)

	-- The type of this schema will implicitly be infered as CFrame
	local exampleSchema = Pack:Define(Pack.CFrame)

	-- For tuples, you must explicitly annotate the type of the schema using Pack.Schema<...>. 
	-- The luau type solver can only infer the first argument.
	local tupleSchema = Pack:Define(Pack.CFrame, Pack.Vector3) :: Pack.Schema<CFrame, Vector3>
	```
]=]
function Pack.Define(_: types.Pack, ...: types.DatatypeInterface<any>): GenericSchema
	local self: _Schema = setmetatable({}, { __index = Schema }) :: any

	local schemas = { ... }

	self._args = #schemas
	self._approxLen = 0
	self._approxBitLen = 0

	self._readers = table.create(self._args) :: { any }
	self._writers = table.create(self._args) :: { any }

	for i, schema in schemas do
		self._readers[i] = schema.Read
		self._writers[i] = schema.Write

		self._approxLen += schema.Len or 0
		self._approxBitLen += schema.BitLen or 0
	end

	return self
end

-- Private type
-- We use a generic version of a schema here, the exported type for pack will apply the correct typing.
type GenericSchema = types.Schema<any>
type _Schema = GenericSchema & {
	_args: number,
	_approxLen: number,
	_approxBitLen: number,
	_readers: { (types.ReaderData) -> any },
	_writers: { (types.WriterData, any) -> () },
}

-- Export types and components for external systems
export type DatatypeInterface<T> = types.DatatypeInterface<T>
export type Schema<T, U...> = types.Schema<T, U...>
export type ReaderData = types.ReaderData
export type WriterData = types.WriterData
export type Datatypes = types.Datatypes

--- @method GetReader
--- @within Pack
--- @return Reader
--- Returns the internal buffer reader library. Use this with Pack.Custom
function Pack.GetReader(_: types.Pack): types.Reader
	return Reader
end

--- @method GetWriter
--- @within Pack
--- @return Writer
--- Returns the internal buffer writer library. Use this with Pack.Custom
function Pack.GetWriter(_: types.Pack): types.Writer
	return Writer
end

--- @method GetBitReader
--- @within Pack
--- @return BitReader
--- Returns the internal bitbuffer reader library. Use this with Pack.Custom
function Pack.GetBitReader(_: types.Pack): types.BitReader
	return require(script.BitReader)
end

--- @method GetBitWriter
--- @within Pack
--- @return BitWriter
--- Returns the internal bitbuffer writer library. Use this with Pack.Custom
function Pack.GetBitWriter(_: types.Pack): types.BitWriter
	return require(script.BitWriter)
end

--- @method GetConfig
--- @within Pack
--- @return { [any]: any }
--- Returns the parsed pack configuration. This will be the same as the pack-config module if it is found, as the parser directly modifies that table.
function Pack.GetConfig(_: types.Pack): { [any]: any }
	return types.cfg
end

--- @method GetSchemaRead
--- @within Pack
--- @return <T, U...>(schema: Schema<T, U...>, T, U...) -> (buffer, refs?)
--- [ADVANCED]: Returns the schema read function so you can skip a namecall operation when reading a packet
function Pack.GetSchemaRead(_)
	return Schema.Read
end

--- @method GetSchemaWrite
--- @within Pack
--- @return <T, U...>(schema: Schema<T, U...>, buff: buffer, refs: refs?) -> (T, U...)
--- [ADVANCED]: Returns the schema write function so you can skip a namecall operation when writing a packet
function Pack.GetSchemaWrite(_)
	return Schema.Write
end

-- Lazy-loading for datatypes so only the necessary datatypes are loaded in each environment
-- This is useful to limit the amount of native code generated when using Pack in parallel luau
function Pack.__index(self: { [string]: any }, key)
	if Pack[key] then return Pack[key] end

	-- Apply alias for lazy-loading
	local aliases = rawget(self, "_aliases")
	key = aliases[key] or key

	-- Lazy-load datatypes
	-- Retrieve from cache if present
	local cache: { [string]: any } = rawget(self, "_cachedDatatypes") :: any
	if cache[key] then return cache[key] end

	-- Load and cache datatype
	local s, datatype = pcall(require :: any, script.Datatypes:FindFirstChild(key :: any))
	assert(s, `Unable to access datatype Pack.{key}. Datatype not found: {datatype}`)
	cache[key] = datatype
	rawset(self, "_cachedDatatypes", cache)
	return datatype
end

local object: types.Pack = setmetatable({
	_cachedDatatypes = {},
	_aliases = {
		UByte = "UInt8",
		UShort = "UInt16",
		UInt = "UInt32",
		ULong = "UInt64",
		Byte = "Int8",
		Short = "Int16",
		Int = "Int32",
		Long = "Int64",
		Float = "Float32",
		Double = "Float64",
		Frac = "Fraction",
		Nil = "Null",
		Struct = "Dictionary",
	},
}, Pack) :: any

return object
