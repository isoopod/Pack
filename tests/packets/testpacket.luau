local Pack = require(game:GetService("ReplicatedStorage").Pack)

local packet = Pack.definePacket(Pack.Dictionary({
	one = Pack.Byte,
	two = Pack.Short,
}))

--local packet = Pack.definePacket(Pack.Array(Pack.UByte))

return packet
