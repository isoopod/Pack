--!strict

-- Modules
local types = require(script.Types)

local Pack = {}

-- Packet class
local Packet = {}

function Packet.Write(self: _Packet) end

function Packet.Read(self: _Packet) end

function Pack.definePacket(--[[Type TODO]]): types.Packet
	local self: _Packet = setmetatable({}, Packet) :: any

	return self
end
-- Private type
type _Packet = types.Packet & {}

---- EXPORTS
-- Load each datatype and export it through pack
-- We need to load each datatype when Pack is required for dynamic packets, so the evaluators can be initialized.

return Pack
