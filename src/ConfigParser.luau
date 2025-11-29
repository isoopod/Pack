local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function VirtualTable(self: any, key: any)
	local new = setmetatable({}, { __index = VirtualTable })
	self[key] = new
	return new
end

local function WrapVirtualStructure(input: any): ()
	for k, v in input do
		if type(v) == "table" then input[k] = WrapVirtualStructure(v) end
	end

	setmetatable(input, { __index = VirtualTable })
end

local Config: { [any]: any }

local packConfig = ReplicatedStorage:FindFirstChild("pack-config")
if packConfig and packConfig.ClassName == "ModuleScript" then
	local s
	s, Config = pcall(require, packConfig)

	if not s then warn("Failed to load pack-config:", Config) end
end

if type(Config) ~= "table" then Config = {} end

WrapVirtualStructure(Config)

return Config
