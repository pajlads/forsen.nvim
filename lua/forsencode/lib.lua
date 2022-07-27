local M = {}
-- map from ascii (int) -> forsen text
M.encTable = {}

function M.encodeString(text)
	local res = ""
	local prev_char_was_invalid = false
	for i = 1, #text do
		local ascii = text:byte(i)
		local char = text:sub(i, i)

		if ascii > 127 then
			res = res .. char
			prev_char_was_invalid = true
		elseif prev_char_was_invalid and char == " " then
			prev_char_was_invalid = false
		else
			prev_char_was_invalid = false
			if not prev_char_was_invalid and res ~= "" then
				res = res .. " "
			end
			local encoded = M.encTable[char]
			res = res .. (encoded or char)
		end
	end
	return res
end

function encodeChar(ascii)
	local res = ""
	if bit.band(ascii, 64) == 0 then
		res = res .. "f"
	else
		res = res .. "F"
	end
	local obit = bit.band(ascii, 48)
	if obit == 0 then
		res = res .. "Ö"
	elseif obit == 16 then
		res = res .. "ö"
	elseif obit == 32 then
		res = res .. "O"
	else
		res = res .. "o"
	end
	if bit.band(ascii, 8) == 0 then
		res = res .. "r"
	else
		res = res .. "R"
	end
	if bit.band(ascii, 4) == 0 then
		res = res .. "s"
	else
		res = res .. "S"
	end
	if bit.band(ascii, 2) == 0 then
		res = res .. "e"
	else
		res = res .. "E"
	end
	if bit.band(ascii, 1) == 0 then
		res = res .. "n"
	else
		res = res .. "N"
	end

	return res
end

function M.decodeString(text)
	local nonCodeStart = 1 -- start of non codeword
	local codeStart = -1
	local accAscii = 0
	local res = ""
	local state = 1 -- 1-6 correspond to waiting each char of forsen
	for i = 1, #text do
		local chr = text:sub(i, i)
		local ascii = text:byte(i)
		if state == 1 then -- expected F
			if chr == "f" then
				codeStart = i
				accAscii = 0
				state = 2
			elseif chr == "F" then
				codeStart = i
				accAscii = 64
				state = 2
			else
				state = 1
			end
		elseif state == 2 then
			if ascii == 195 then
				state = 2.5
			elseif chr == "O" then
				accAscii = accAscii + 32
				state = 3
			elseif chr == "o" then
				accAscii = accAscii + 48
				state = 3
			else
				state = 1
			end
		elseif state == 2.5 then
			if ascii == 150 then
				-- accAscii = accAscii + 0
				state = 3
			elseif ascii == 182 then
				accAscii = accAscii + 16
				state = 3
			else
				state = 1
			end
		elseif state == 3 then
			if chr == "R" then
				accAscii = accAscii + 8
				state = 4
			elseif chr == "r" then
				-- accAscii = accAscii + 0
				state = 4
			else
				state = 1
			end
		elseif state == 4 then
			if chr == "S" then
				accAscii = accAscii + 4
				state = 5
			elseif chr == "s" then
				-- accAscii = accAscii + 0
				state = 5
			else
				state = 1
			end
		elseif state == 5 then
			if chr == "E" then
				accAscii = accAscii + 2
				state = 6
			elseif chr == "e" then
				-- accAscii = accAscii + 0
				state = 6
			else
				state = 1
			end
		elseif state == 6 then
			if chr == "N" or chr == "n" then
				state = 1
				if chr == "N" then
					accAscii = accAscii + 1
				end
				-- decode
				-- skip blank
				if text:byte(nonCodeStart) == 32 then -- space
					nonCodeStart = nonCodeStart + 1
				end
				res = res .. text:sub(nonCodeStart, codeStart - 1) .. string.char(accAscii)
				nonCodeStart = i + 1
			else
				state = 1
			end
		end
	end
	if nonCodeStart <= #text then
		res = res .. text:sub(nonCodeStart, #text)
	end
	return res
end
-- pre-encode dank
for ascii = 32, 126 do
	local char = string.char(ascii)
	M.encTable[char] = encodeChar(ascii)
end
-- tab
local char = string.char(9)
M.encTable[char] = encodeChar(9)

return M
