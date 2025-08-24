--!strict

return function(b: buffer, error: string?)
	local hex = {}
	local decimal = {}
	for i = 0, buffer.len(b) - 1 do
		table.insert(hex, string.format("%02X", buffer.readu8(b, i)))
		table.insert(decimal, buffer.readu8(b, i))
	end

	local dump = `Buffer Details:\nLength: {buffer.len(b)}\nHex: {table.concat(hex, " ")}\nDecimal: {table.concat(decimal, " ")}`
	if error then
		return `{error}\n{dump}`
	else
		return dump
	end
end
