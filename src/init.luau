--!strict
--!native
--!optimize 2

-- Modules
local Reader = require(script.Reader)
local Writer = require(script.Writer)
local types = require(script.Types)

local Pack = {}

-- Schema class
--[=[
	@class Schema

	A schema is needed to read and write a packet with a particular data structure.  
	Schemas are created through Pack:Define() through combinations of pack datatypes.  

	Once created, a schema holds the Read and Write methods to serialize and deserialize data to and from packets (buffers).
]=]
local Schema = {}

--- @method
--- @within Schema
--- @param input any
--- @return buffer -- This is your 'packet' that can be sent around or stored and later read by this schema.
--- @return {any} -- Table of refs for datatypes making use of this. Stock Pack does not use this and this is intended for Networking.
--- Writes a packet (buffer) from the provided input, which should follow the structure of the schema.
function Schema.Write(self: _Schema, ...: any): (buffer, types.refs?)
	local refs = {}
	local writer = Writer.new()
	writer.refs = refs

	local input = { ... }
	for i = 1, self._args do
		self._writers[i](writer, input[i])
	end

	local packed = writer:Finalize()
	return packed, #refs > 0 and refs or nil
end

--- @method
--- @within Schema
--- @param packet buffer -- A packet created by this schema with the Write method.
--- @param refs {any}? -- Optional table of refs for datatypes making use of this. Stock Pack does not use this and this is intended for Networking.
--- @return any -- This is a reconstruction of the input to the packet.
--- Reads a packet (buffer) that was written with the same schema and outputs a reconstruction of the packet's input.
function Schema.Read(self: _Schema, packet: buffer, refs: types.refs?): ...any
	local reader = Reader.new(packet)
	reader.refs = refs :: any

	local tuple = table.create(self._args)
	for i = 1, self._args do
		tuple[i] = self._readers[i](reader)
	end

	return unpack(tuple)
end

function Pack.Define(_: types.Pack, ...: types.DatatypeInterface<any>): GenericSchema
	local self: _Schema = setmetatable({}, { __index = Schema }) :: any

	local schemas = { ... }

	self._args = #schemas
	self._readers = table.create(self._args) :: { any }
	self._writers = table.create(self._args) :: { any }

	for i, schema in schemas do
		self._readers[i] = schema.Read
		self._writers[i] = schema.Write
	end

	return self
end
-- Private type
-- We use a generic version of a schema here, the exported type for pack will apply the correct typing.
type GenericSchema = types.Schema<any>
type _Schema = GenericSchema & {
	_args: number,
	_readers: { (types.Reader) -> any },
	_writers: { (types.Writer, any) -> () },
}

-- Lazy-loading for datatypes so only the neccesary datatypes are loaded on each thread
-- This is useful to limit the amount of native code generated when using Pack in parallel luau
function Pack.__index(self, key)
	if Pack[key] then return Pack[key] end

	-- Apply alias for lazy-loading
	local aliases = rawget(self, "_aliases") :: { [string]: string }
	key = aliases[key] or key

	-- Lazy-load datatypes
	-- Retrieve from cache if present
	local cache: { [string]: any } = rawget(self, "_cachedDatatypes") :: any
	if cache[key] then return cache[key] end

	-- Load and cache datatype
	local s, datatype = pcall(require, script.Datatypes:FindFirstChild(key))
	assert(s, `Unable to access datatype Pack.{key}. Datatype not found.`)
	cache[key] = datatype
	rawset(self, "_cachedDatatypes", cache)
	return datatype
end

local object: types.Pack = setmetatable({
	_cachedDatatypes = {},
	_aliases = {
		UByte = "uint8",
		UShort = "uint16",
		UInt = "uint32",
		Byte = "int8",
		Short = "int16",
		Int = "int32",
		Float = "float32",
		Double = "float64",
	},
}, Pack) :: any

-- If you are using the tuple system, you wont be able to get automatic type completion for more than 1 argument
-- Therefore you have to define it as a manual tuple.
-- Example Usage: local schema = Pack:Define(Pack.CFrame, Pack.Vector3) :: Pack.ManualTuple<CFrame, Vector3>
export type ManualTuple<T, U...> = types.Schema<T, U...>

return object
