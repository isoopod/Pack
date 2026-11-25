--!native
--!optimize 2

const BitReader = require(script.Parent.Parent.BitReader)
const BitWriter = require(script.Parent.Parent.BitWriter)
const Evaluator = require(script.Parent.Parent.Evaluator)
const types = require(script.Parent.Parent.types)

const DEBUG = types.DEBUG

const bitr_read = BitReader.read

const bitw_alloc = BitWriter.alloc
const bitw_write = BitWriter.write

return function(...: types.DatatypeInterface<any>): types.DatatypeInterface<any>
	const args = { ... }

	const bits = math.floor(math.log(#args, 2)) + 1

	if DEBUG then DEBUG.Union.CheckDatatypesSupported(args) end

	return table.freeze({
		BitLen = bits,
		Read = function(reader: types.ReaderData): any
			const i = bitr_read(reader, bits) + 1
			return args[i].Read(reader)
		end,
		Write = function(writer: types.WriterData, value: any)
			for i, dt in args do
				if not dt.Eval then continue end
				if not Evaluator.evaluators[dt.Eval] then error(`No evaluator for datatype {dt.Eval}`) end
				if Evaluator.evaluators[dt.Eval](value, dt) then
					bitw_alloc(writer, bits)
					bitw_write(writer, bits, i - 1)
					dt.Write(writer, value)
					return
				end
			end
			error(`{typeof(value)} '{value}' could not be represented by datatype union.`)
		end,
	}) :: types.DatatypeInterface<any>
end
