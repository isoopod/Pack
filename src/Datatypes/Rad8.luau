--!native
--!optimize 2

const Reader = require(script.Parent.Parent.Reader)
const Writer = require(script.Parent.Parent.Writer)
const types = require(script.Parent.Parent.types)

const read_u8 = Reader.u8

const write_alloc = Writer.alloc
const write_u8 = Writer.u8

const TAU = 2 * math.pi
const TAU_INVERSE = 1 / TAU
const PRECISION = 0xff
const PRECISION_INVERSE = 1 / PRECISION

const datatype = table.freeze({
	Eval = "rad8",
	Len = 1,
	Read = function(reader: types.ReaderData): number
		const byte = read_u8(reader)
		return byte * (PRECISION_INVERSE * TAU)
	end,
	Write = function(writer: types.WriterData, value: number)
		write_alloc(writer, 1)

		value %= TAU
		write_u8(writer, (value * (TAU_INVERSE * PRECISION) + 0.5) // 1)
	end,
}) :: types.DatatypeInterface<number>

return datatype
