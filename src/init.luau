--!strict

-- Modules
local Reader = require(script.Reader)
local Writer = require(script.Writer)
local types = require(script.Types)

local Pack = {}

-- Packet class
local Packet = {}

function Packet.Write<T>(self: _Packet<T>, value: types.DatatypeInterface<T>)
	local writer = Writer.new()
	self._write(writer, value)

	local packed = writer:Finalize()
	return packed
end

function Packet.Read<T>(self: _Packet<T>, packed: buffer)
	local reader = Reader.new(packed)

	local unpacked = self._read(reader)
	reader:Destroy()
	return unpacked
end

function Pack.definePacket<T>(props: types.DatatypeInterface<T>): types.Packet<T>
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
Pack.Array = require(datatypes.Array)
Pack.uint8 = require(datatypes.uint8)
Pack.UByte = Pack.uint8

return Pack
