--!strict
--!native
--!optimize 2

local Evaluator = require(script.Parent.Parent.Evaluator)
local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

local DEBUG = types.DEBUG

local read_u8 = Reader.u8

local write_alloc = Writer.alloc
local write_u8 = Writer.u8

return function(...: types.DatatypeInterface<any>): types.DatatypeInterface<any>
	local args = { ... }

	if DEBUG then DEBUG.Union.CheckDatatypesSupported(args) end

	return table.freeze({
		Read = function(reader: types.ReaderData): any
			local i = read_u8(reader)
			return args[i].Read(reader)
		end,
		Write = function(writer: types.WriterData, value: any)
			for i, dt in args do
				if not dt.Eval then continue end
				if not Evaluator.evaluators[dt.Eval] then error(`No evaluator for datatype {dt.Eval}`) end
				if Evaluator.evaluators[dt.Eval](value, dt) then
					write_alloc(writer, 1)
					write_u8(writer, i)
					dt.Write(writer, value)
				end
			end
			error(`{typeof(value)} '{value}' could not be represented by datatype union.`)
		end,
	}) :: types.DatatypeInterface<any>
end
