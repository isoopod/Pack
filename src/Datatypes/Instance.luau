--!strict
--!native
--!optimize 2

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local types = require(script.Parent.Parent.Types)

local IN_ACTOR = script:GetActor() ~= nil
local IS_SERVER = RunService:IsServer()
local PACK_CONFIG = (IS_SERVER and SharedTableRegistry:GetSharedTable("PACK_CONFIG")) :: SharedTable

local PREFIX = IS_SERVER and "PACK_SREF" or "PACK_CREF"

local Instance_Refs = SharedTableRegistry:GetSharedTable("PACK_INSTANCE_REFS")

-- WARNING: Instances cannot cross the server client boundary this way, if you are making a networking library using Pack, pass instances in a seperate refs table
-- This is targetted towards serializing instances to send through SharedTables
-- If you are sending messages to actors or using bindables, the seperate refs table is also preferential, put a unsigned int in the packet for the index of that table.

-- You cannot write Instances in parallel, however reading can be done in parallel. Again, using a seperate refs table would allow parallel writing.

-- You can enable this to have the server ref count save on close, allowing refs to persist in saving places
local setcount: (number) -> ()
if IS_SERVER and PACK_CONFIG.PERSIST_INSTACE_REFS then
	setcount = function(count: number)
		script:SetAttribute("n", count)
	end
	Instance_Refs.count = script:GetAttribute("n") or -1
end

local datatype: types.DatatypeInterface<Instance?> = {
	Read = function(Reader: types.Reader): Instance?
		local ref = Reader:u32()

		return CollectionService:GetTagged(`{PREFIX}{ref}`)[1]
	end,
	Write = function(Writer: types.Writer, value: Instance?)
		assert(value and typeof(value) == "Instance", "Value expected to be an Instance")

		-- Check if the instance has an existing ref
		local ref: number
		for _, v in value:GetTags() do
			if string.sub(v, 1, 9) == PREFIX then
				ref = tonumber(string.sub(v, 10)) :: number
				break
			end
		end
		if not ref then
			-- Otherwise, reserve a new ref

			if IN_ACTOR then task.synchronize() end -- Go to serial mode
			SharedTable.increment(Instance_Refs, "count", 1)
			ref = Instance_Refs.count
			value:AddTag(`{PREFIX}{ref}`)
			if setcount then setcount(ref) end
		end

		Writer:alloc(4)
		Writer:u32(ref)
	end,
}

return datatype
