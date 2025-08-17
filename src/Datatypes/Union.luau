--!strict
--!native
--!optimize 2

local BitReader = require(script.Parent.Parent.BitReader)
local BitWriter = require(script.Parent.Parent.BitWriter)
local Evaluator = require(script.Parent.Parent.Evaluator)
local types = require(script.Parent.Parent.types)

local DEBUG = types.DEBUG

local bitr_read = BitReader.read

local bitw_alloc = BitWriter.alloc
local bitw_write = BitWriter.write

return function(...: types.DatatypeInterface<any>): types.DatatypeInterface<any>
	local args = { ... }

	local bits = math.floor(math.log(#args, 2)) + 1

	if DEBUG then DEBUG.Union.CheckDatatypesSupported(args) end

	return table.freeze({
		BitLen = bits,
		Read = function(reader: types.ReaderData): any
			local i = bitr_read(reader, bits)
			return args[i].Read(reader)
		end,
		Write = function(writer: types.WriterData, value: any)
			for i, dt in args do
				if not dt.Eval then continue end
				if not Evaluator.evaluators[dt.Eval] then error(`No evaluator for datatype {dt.Eval}`) end
				if Evaluator.evaluators[dt.Eval](value, dt) then
					bitw_alloc(writer, bits)
					bitw_write(writer, bits, i)
					dt.Write(writer, value)
					return
				end
			end
			error(`{typeof(value)} '{value}' could not be represented by datatype union.`)
		end,
	}) :: types.DatatypeInterface<any>
end
