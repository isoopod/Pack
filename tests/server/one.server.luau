-- Until I add TestEZ ill just be doing basic tests in here to make sure things are working

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testpacket = require(ReplicatedStorage.Packets.testpacket)

local before = { one = 1, two = 2 }
local packet = testpacket:Write(before)
local after = testpacket:Read(packet)

print(before, after)
