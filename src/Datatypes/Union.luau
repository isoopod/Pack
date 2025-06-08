--!strict
--!native
--!optimize 2

local Evaluator = require("../Evaluator")
local Reader = require("../Reader")
local Writer = require("../Writer")
local types = require("../types")

local read_u8 = Reader.u8

local write_alloc = Writer.alloc
local write_u8 = Writer.u8

return function(...: types.DatatypeInterface<any>): types.DatatypeInterface<any>
	local args = { ... }
	return table.freeze({
		Read = function(reader: types.ReaderData): any
			local i = read_u8(reader)
			return args[i].Read(reader)
		end,
		Write = function(writer: types.WriterData, value: any)
			for i, dt in args do
				if not dt.Eval then continue end
				if Evaluator.evaluators[dt.Eval](value, dt) then
					write_alloc(writer, 1)
					write_u8(writer, i)
					dt.Write(writer, value)
				end
			end
			error(`{value} could not be represented by datatype union.`)
		end,
	}) :: types.DatatypeInterface<any>
end
