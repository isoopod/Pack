--!strict
--!native
--!optimize 2

local BitReader = require(script.Parent.Parent.BitReader)
local BitWriter = require(script.Parent.Parent.BitWriter)
local types = require(script.Parent.Parent.types)

local bitr_read = BitReader.read

local bitw_alloc = BitWriter.alloc
local bitw_write = BitWriter.write

local datatype = table.freeze({
	Eval = "bool",
	Read = function(reader: types.ReaderData): boolean
		return bitr_read(reader, 1) == 1
	end,
	Write = function(writer: types.WriterData, value: boolean)
		bitw_alloc(writer, 1)
		bitw_write(writer, 1, value and 1 or 0)
	end,
}) :: types.DatatypeInterface<boolean>

return datatype
