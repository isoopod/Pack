--!native
--!optimize 2

-- 2025/02/5: Enum:FromValue and Enum:FromName are not recognised by Luau LSP, so this file will not use strict mode for now.

local types = require(script.Parent.Parent.Types)

return function(enum: Enum): types.DatatypeInterface<EnumItem>
	return {
		Read = function(Reader: types.Reader): EnumItem
			return enum:FromValue(Reader:u16()) :: EnumItem
		end,
		Write = function(Writer: types.Writer, value: EnumItem)
			-- Some useful enumitems values like materials and keycodes are above 256
			-- Therefore, we have to use an u16 instead. The only enum this does not work for is ReservedHighlightId
			-- Which isn't usable anyway (as far as I know)
			Writer:alloc(2)
			Writer:u16(value.Value)
		end,
	}
end
