-- Until I add TestEZ ill just be doing basic tests in here to make sure things are working

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local testpacket = require(ReplicatedStorage.Packets.testpacket)

local before = { 5, 3, 1, 2, 4 }
local packet = testpacket:Write(before)
local after = testpacket:Read(packet)

print(before, after)
