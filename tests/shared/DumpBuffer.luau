--!strict

local function toBinaryString(n: number): string
	local result = {}
	for i = 7, 0, -1 do
		local bit = bit32.band(bit32.rshift(n, i), 1)
		table.insert(result, bit == 1 and "1" or "0")
	end
	return table.concat(result)
end

return function(b: buffer, error: string?)
	local hex = {}
	local decimal = {}
	local binary = {}
	for i = 0, buffer.len(b) - 1 do
		local n = buffer.readu8(b, i)
		table.insert(hex, string.format("%02X", n))
		table.insert(decimal, n)
		table.insert(binary, toBinaryString(n))
	end

	local dump = `Buffer Details:\nLength: {buffer.len(b)}\nHex: {table.concat(hex, " ")}\nDecimal: {table.concat(decimal, " ")}\nBinary: {table.concat(binary, " ")}`
	if error then
		return `{error}\n{dump}`
	else
		return dump
	end
end
