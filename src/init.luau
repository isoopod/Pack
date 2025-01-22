--!strict

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
--- Writes a packet (buffer) from the provided input, which should follow the structure of the schema.
function Schema.Write<T>(self: _Schema<T>, input: T): buffer
	local writer = Writer.new()
	self._write(writer, input)

	local packed = writer:Finalize()
	return packed
end

--- @method
--- @within Schema
--- @param packet buffer -- A packet created by this schema with the Write method.
--- @return any -- This is a reconstruction of the input to the packet.
--- Reads a packet (buffer) that was written with the same schema and outputs a reconstruction of the packet's input.
function Schema.Read<T>(self: _Schema<T>, packet: buffer): T
	local reader = Reader.new(packet)

	local unpacked = self._read(reader)
	reader:Destroy()
	return unpacked
end

function Pack.Define<T>(_: types.Pack, schema: T & types.DatatypeInterface<any>): types.Schema<T>
	local self: _Schema<T> = setmetatable({}, { __index = Schema }) :: any

	self._read = schema.Read
	self._write = schema.Write

	return self
end
-- Private type
type _Schema<T> = types.Schema<T> & {
	_read: (types.Reader) -> T,
	_write: (types.Writer, T, any?) -> (),
}

function Pack.__index(self, key)
	if Pack[key] then return Pack[key] end

	-- Apply alias for lazy-loading
	local aliases = rawget(self, "_aliases") :: { [string]: string }
	key = aliases[key] or key

	-- Lazy-load datatypes
	-- Retrieve from cache if present
	local cache: { [string]: any } = rawget(self, "_cachedDataypes") :: any
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

return object
