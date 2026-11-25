--!optimize 2

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const function VirtualTable(self: any, key: any)
	const new = setmetatable({}, { __index = VirtualTable })
	self[key] = new
	return new
end

const function WrapVirtualStructure(input: any)
	for k, v in input do
		if type(v) == "table" then input[k] = WrapVirtualStructure(v) end
	end

	return setmetatable(input, { __index = VirtualTable })
end

local Config: { [any]: any }

const packConfig = ReplicatedStorage:FindFirstChild("pack-config")
if packConfig and packConfig.ClassName == "ModuleScript" then
	local s
	s, Config = pcall(require, packConfig)

	if not s then warn("Failed to load pack-config:", Config) end
end

if type(Config) ~= "table" then Config = {} end

WrapVirtualStructure(Config)

return Config
