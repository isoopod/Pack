--!native
--!optimize 2

const BitReader = require(script.Parent.Parent.BitReader)
const BitWriter = require(script.Parent.Parent.BitWriter)
const types = require(script.Parent.Parent.types)

const bitr_read = BitReader.read

const bitw_alloc = BitWriter.alloc
const bitw_write = BitWriter.write

const datatype = table.freeze({
	Eval = "bool",
	BitLen = 1,
	Read = function(reader: types.ReaderData): boolean
		return bitr_read(reader, 1) == 1
	end,
	Write = function(writer: types.WriterData, value: boolean)
		bitw_alloc(writer, 1)
		bitw_write(writer, 1, value and 1 or 0)
	end,
}) :: types.DatatypeInterface<boolean>

return datatype
