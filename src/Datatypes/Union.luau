--!strict
--!native
--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Evaluator = require(ReplicatedStorage.Pack.Evaluator)
local Reader = require(script.Parent.Parent.Reader)
local Writer = require(script.Parent.Parent.Writer)
local types = require(script.Parent.Parent.types)

return function(...: types.DatatypeInterface<any>): types.DatatypeInterface<any>
	local args = { ... }
	return table.freeze({
		Read = function(reader: types.ReaderData): any
			local dt = Reader.u8(reader)
			return require(Evaluator.indexToDatatype[dt]).Read(reader)
		end,
		Write = function(writer: types.WriterData, value: any)
			for _, dt in args do
				if not dt.Eval then continue end
				if Evaluator.evaluators[dt.Eval](value, dt) then
					Writer.u8(writer, Evaluator.evalToId[dt.Eval])
					dt.Write(writer, value)
				end
			end
			error(`{value} could not be represented by datatype union.`)
		end,
	}) :: types.DatatypeInterface<any>
end
