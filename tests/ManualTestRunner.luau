-- Require this module from the command bar in a local test
-- Also, make sure loadstring is enabled.

if not game:GetService("RunService"):IsRunning() then error("Only run TestRunner in a local test.") end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local runCLI = require(ReplicatedStorage.DevPackages.Jest).runCLI

local status, result = runCLI(ReplicatedStorage.shared, {
	verbose = false,
	ci = false,
}, { ReplicatedStorage.shared }):awaitStatus()

if status == "Rejected" then print(result) end

return nil
