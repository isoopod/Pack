--!strict
--!native
--!optimize 2

local types = require(script.Parent.Parent.Types)

local datatype: types.DatatypeInterface<BrickColor> = {
	Read = function(Reader: types.Reader): BrickColor
		return BrickColor.new(Reader:u16())
	end,
	Write = function(Writer: types.Writer, value: BrickColor)
		Writer:alloc(2)
		Writer:u16(value.Number)
	end,
}

return datatype
