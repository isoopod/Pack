local Pack = require(game:GetService("ReplicatedStorage").Pack)

-- local packet = Pack:Define(Pack.Dictionary({
-- 	one = Pack.Byte,
-- 	two = Pack.Short,
-- }))

--local packet = Pack:Define(Pack.Array(Pack.UByte))

local packet = Pack:Define(Pack.CFrame)

return packet
