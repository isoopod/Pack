--!strict
--!native
--!optimize 2

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local SharedTableRegistry = game:GetService("SharedTableRegistry")

local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local read_u32 = Reader.u32

local write_alloc = Writer.alloc
local write_u32 = Writer.u32

local IN_ACTOR = script:GetActor() ~= nil
local IS_SERVER = RunService:IsServer()

local PREFIX = IS_SERVER and "PACK_SREF" or "PACK_CREF"

local Instance_Refs = SharedTableRegistry:GetSharedTable("PACK_INSTANCE_REFS")

-- WARNING: Instances cannot cross the server client boundary this way, if you are making your own networking library using Pack, pass instances in a separate refs table.
-- This is targetted towards serializing references to instances to send through SharedTables.
-- If you are sending messages to actors or using bindables, the separate refs table is also preferential, put a unsigned int in the packet for the index of that table.
-- Or see how PakNet's Ref datatype works.

-- You cannot write Instances in parallel, however reading can be done in parallel. Again, using a separate refs table would allow parallel writing.

-- You can enable this to have the server ref count save on close, allowing refs to persist in saving places.
local setcount: (number) -> ()
if IS_SERVER and types.cfg.persistInstanceRefs then setcount = function(count: number)
	script:SetAttribute("n", count)
end end
Instance_Refs.count = script:GetAttribute("n") or -1

local datatype = table.freeze({
	Eval = "Inst_Ref",
	Len = 4,
	Read = function(reader: types.ReaderData): Instance?
		local ref = read_u32(reader)

		return CollectionService:GetTagged(`{PREFIX}{ref}`)[1]
	end,
	Write = function(writer: types.WriterData, value: Instance?)
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
			if setcount then (setcount :: any)(ref) end
		end

		write_alloc(writer, 4)
		write_u32(writer, ref)
	end,
}) :: types.DatatypeInterface<Instance?>

return datatype
