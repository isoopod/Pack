--!strict

-- Modules
local Reader = require(script.Reader)
local Writer = require(script.Writer)
local types = require(script.Types)

local Pack = {}

-- Packet class
local Packet = {}

function Packet.Write<T>(self: _Packet<T>, value: T): buffer
	local writer = Writer.new()
	self._write(writer, value)

	local packed = writer:Finalize()
	return packed
end

function Packet.Read<T>(self: _Packet<T>, payload: buffer): T
	local reader = Reader.new(payload)

	local unpacked = self._read(reader)
	reader:Destroy()
	return unpacked
end

function Pack.definePacket<T>(props: T & types.DatatypeInterface<any>): types.Packet<T>
	local self: _Packet<T> = setmetatable({}, { __index = Packet }) :: any

	self._read = props.Read
	self._write = props.Write

	return self
end
-- Private type
type _Packet<T> = types.Packet<T> & {
	_read: (types.Reader) -> T,
	_write: (types.Writer, T, any?) -> (),
}

---- EXPORTS
-- Load each datatype and export it through pack
-- We need to load each datatype when Pack is required for dynamic packets, so the evaluators can be initialized.
local datatypes = script.Datatypes
-- [[ Number Types ]]
-- Integers --
-- Unsigned
Pack.uint8 = require(datatypes.uint8) :: number
Pack.UByte = Pack.uint8
Pack.uint16 = require(datatypes.uint16) :: number
Pack.UShort = Pack.uint16
Pack.uint32 = require(datatypes.uint32) :: number
Pack.UInt = Pack.uint32
-- Signed
Pack.int8 = require(datatypes.int8) :: number
Pack.Byte = Pack.int8
Pack.int16 = require(datatypes.int16) :: number
Pack.Short = Pack.int16
Pack.int32 = require(datatypes.int32) :: number
Pack.Int = Pack.int32

-- Floating Point --
Pack.float32 = require(datatypes.float32) :: number
Pack.Float = Pack.float32
Pack.float64 = require(datatypes.float64) :: number
Pack.Double = Pack.float64

-- [[ Other Basic ]]
-- Boolean --
Pack.boolean = require(datatypes.boolean) :: boolean
Pack.BitField = require(datatypes.BitField) :: (length: number) -> { boolean }

-- [[ Structural types ]]
Pack.Array = require(datatypes.Array) :: <T>(type: T) -> { T }
Pack.Dictionary = require(datatypes.Dictionary) :: <T>(format: T) -> T
return Pack
