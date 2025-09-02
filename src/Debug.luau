--!strict

local TestService = game:GetService("TestService")

local ConfigParser = require(script.Parent.ConfigParser)

-- Any debug logic should be written here to reduce the amount of native code

--[=[
	@class Logger
	A simple logger class for debugging purposes.
]=]

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

--[=[
	@function new
	@within Logger
	@param prefix string? -- Optional prefix for log lines.
	@return Logger
	Creates a new Logger instance with an optional prefix.
]=]
function Logger.new(prefix: string?): Logger
	local self = {
		_status = 0,
		_lines = {} :: { string },
		_prefix = prefix or "",
	}
	return setmetatable(self, Logger) :: any
end

--[=[
	@method AddLine
	@within Logger
	@param line string -- The line to add to the log.
	Adds a line to the logger with the current prefix.
]=]
function Logger.AddLine(self: _Logger, line: string)
	table.insert(self._lines, `{self._prefix}{line}`)
end

--[=[
	@method Get
	@within Logger
	@return string -- The concatenated log lines.
	Retrieves the current log as a single string.
]=]
function Logger.Get(self: _Logger): string
	return table.concat(self._lines, "\n")
end

--[=[
	@method Clear
	@within Logger
	Clears all log lines.
]=]
function Logger.Clear(self: _Logger)
	table.clear(self._lines)
end

--[=[
	@method SetPrefix
	@within Logger
	@param prefix string -- The new prefix for log lines.
	Sets a new prefix for the logger.
]=]
function Logger.SetPrefix(self: _Logger, prefix: string)
	self._prefix = prefix
end

--[=[
	@method SetStatus
	@within Logger
	@param status number -- The status code (0: success, 1: warning, 2: error).
	Sets the status of the logger, allowing for different log levels.
]=]
function Logger.SetStatus(self: _Logger, status: number)
	self._status = math.max(self._status, status)
end

--[=[
	@method StackTrace
	@within Logger
	@param start number? -- Optional starting point for the stack trace.
	Logs the current stack trace starting from the specified point.
]=]
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

--[=[
	@method WriteLogs
	@within Logger
	Prints the logs to the console based on the status.
	If status is 0, it prints a message. If 1, it warns. If 2, it errors.
]=]
function Logger.WriteLogs(self: _Logger)
	if self._status == 0 then
		if ConfigParser.debug.verbose then TestService:Message(self:Get(), script, debug.info(2, "l")) end
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

debuggers.EnforceDatatype = {
	AnyNumeric = function(dt: any)
		if
			type(dt) ~= "table"
			or (
				dt.Eval ~= "u8"
				and dt.Eval ~= "u16"
				and dt.Eval ~= "u32"
				and dt.Eval ~= "u64"
				and dt.Eval ~= "i8"
				and dt.Eval ~= "i16"
				and dt.Eval ~= "i32"
				and dt.Eval ~= "i64"
				and dt.Eval ~= "f32"
				and dt.Eval ~= "f64"
				and dt.Eval ~= "frac"
			)
		then
			local dtype = "unknown"
			if type(dt) == "table" and (dt :: any).Write and type((dt :: any).Write) == "function" then dtype = debug.info((dt :: any).Write :: () -> (), "s") end
			warn(`This datatype expects the provided value type to be numeric. Got {dtype}`)
		end
	end,
	AnyColor3 = function(dt: any)
		if type(dt) ~= "table" or (dt.Eval ~= "Color3" and dt.Eval ~= "Color3float32") then
			local dtype = "unknown"
			if type(dt) == "table" and (dt :: any).Write and type((dt :: any).Write) == "function" then dtype = debug.info((dt :: any).Write :: () -> (), "s") end
			warn(`This datatype expects the provided value type to be Color3. Got {dtype}`)
		end
	end,
}

debuggers.Array = {
	CheckLenType = function(t: any)
		if type(t) ~= "table" or t.Eval == nil or not string.match(t.Eval :: any, "^u%d%d?$") then
			local dt = "unknown"
			if type(t) == "table" and (t :: any).Write and type(t.Write) == "function" then dt = debug.info(t.Write :: () -> (), "s") end
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
