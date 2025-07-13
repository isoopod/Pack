--!strict

local SharedTableRegistry = game:GetService("SharedTableRegistry")
local TestService = game:GetService("TestService")
local PACK_CONFIG = SharedTableRegistry:GetSharedTable("PACK_CONFIG")

-- Any debug logic should be written here to reduce the amount of native code

local Logger = {}
Logger.__index = Logger

export type Logger = {
	AddLine: (self: Logger, line: string) -> (),
	Get: (self: Logger) -> string,
	Clear: (self: Logger) -> (),
	SetPrefix: (self: Logger, prefix: string) -> (),
	SetStatus: (self: Logger, status: number) -> (), -- 0: success 1: warning 2: error
	StackTrace: (self: Logger, start: number?) -> (),
	WriteLogs: (self: Logger) -> (),
}

type _Logger = Logger & {
	_status: number,
	_lines: { string },
	_prefix: string,
}

function Logger.new(prefix: string?): Logger
	local self = {
		_status = 0,
		_lines = {} :: { string },
		_prefix = prefix or "",
	}
	return setmetatable(self, Logger) :: any
end

function Logger.AddLine(self: _Logger, line: string)
	table.insert(self._lines, `{self._prefix}{line}`)
end

function Logger.Get(self: _Logger): string
	return table.concat(self._lines, "\n")
end

function Logger.Clear(self: _Logger)
	table.clear(self._lines)
end

function Logger.SetPrefix(self: _Logger, prefix: string)
	self._prefix = prefix
end

function Logger.SetStatus(self: _Logger, status: number)
	self._status = math.max(self._status, status)
end

function Logger.StackTrace(self: _Logger, start: number?)
	self:AddLine("Stacktrace:\n")
	for i = (start or 1), 100 do -- Limit to 100 layers
		local source: string, name: string, line: number = debug.info(i, "snl")
		if not source then
			self:AddLine("\tStacktrace truncated at 100 lines.")
			break
		end
		if line >= 0 then
			self:AddLine(string.format("\t%s(%d): %s", source, line, name or "anonymous"))
		else
			self:AddLine(string.format("\t%s: %s", source, name or "anonymous"))
		end
	end
end

function Logger.WriteLogs(self: _Logger)
	if self._status == 0 then
		if PACK_CONFIG.Verbose then TestService:Message(self:Get(), script, debug.info(2, "l")) end
		return
	end

	self:StackTrace(2)

	if self._status == 1 then
		warn(self:Get())
	elseif self._status == 2 then
		TestService:Error(self:Get())
	end
end

local debuggers = {}

debuggers.Array = {
	CheckLenType = function(t: any)
		if type(t) ~= "table" or t.Eval == nil or not string.match(t.Eval :: any, "^u%d%d?$") then
			local dt = "unknown"
			if type(t) == "table" and t.Write and type(t.Write) == "function" then dt = debug.info(t.Write :: () -> (), "s") end
			warn(`Arrays should only use unsigned integers for lengthType. Got {dt}`)
		end
	end,
}

debuggers.SparseDictionary = {
	CheckRequired = function(required: { any }, values: { [any]: any })
		local logs = Logger.new()
		for _, key in required do
			if not values[key] then
				logs:SetStatus(2)
				logs:AddLine(`[ERROR]: SparseDictionary expecting required key {key}, got nil`)
			end
		end
		logs:WriteLogs()
	end,
}

debuggers.Union = {
	CheckDatatypesSupported = function(args: { any })
		local logs = Logger.new()
		for _, dt in args do
			if not dt.Eval then
				logs:SetStatus(2)
				-- FIXME: See if there is some way to get the file this datatype comes from
				logs:AddLine(`[ERROR]: Union does not support this datatype`)
			end
		end
		logs:WriteLogs()
	end,
}

return debuggers
