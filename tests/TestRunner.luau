local processServiceExists, ProcessService = pcall(function()
	local service = "ProcessService"
	return game:GetService(service)
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local runCLI = require(ReplicatedStorage.DevPackages.Jest).runCLI

local status, result = runCLI(ReplicatedStorage.shared, {
	verbose = false,
	ci = true,
}, { ReplicatedStorage.shared }):awaitStatus()

if status == "Rejected" then print(result) end

if status == "Resolved" and result.results.numFailedTestSuites == 0 and result.results.numFailedTests == 0 then
	if processServiceExists then ProcessService:ExitAsync(0) end
end

if processServiceExists then ProcessService:ExitAsync(1) end
