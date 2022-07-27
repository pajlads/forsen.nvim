local M = {}
print("forsenE")

local function toForsen(ascii)
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

local enc = {}

-- pre-encode dank
for ascii = 32, 126 do
	local char = string.char(ascii)
	enc[char] = toForsen(ascii)
end
-- tab
local char = string.char(9)
enc[char] = toForsen(9)

-- NOTE: I deliberately don't encode 0-31 (which include <Space>, <CR>, <LF>, <Tab>) to allow text to be formatted
-- WARN this doesn't save & restore keybinding, so plugins that have mappings in insert mode can be broken

local function addKeyMapping()
	-- map
	for ascii = 32, 126 do
		local char = string.char(ascii)
		vim.keymap.set("i", char, enc[char] .. " ", { buffer = 0 })
	end
	local char = string.char(9)
	vim.keymap.set("i", char, enc[char] .. " ", { buffer = 0 })

	vim.keymap.set("i", "<CR>", function()
		local cursor = vim.api.nvim_win_get_cursor(0)
		local row = cursor[1] - 1
		local rowText = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or "" -- only one line
		if rowText:sub(#rowText, #rowText) == " " then
			rowText = rowText:sub(1, #rowText - 1)
			vim.api.nvim_buf_set_lines(0, row, row + 1, false, { rowText })
		end
		vim.api.nvim_input([[<C-R>="\n"<CR>]])
	end)
end

local function removeKeyMapping()
	-- unmap
	for ascii = 32, 126 do
		-- let's do "try catch" to not error when key isn't mapped
		pcall(vim.keymap.del, "i", string.char(ascii), { buffer = 0 })
	end
	pcall(vim.keymap.del, "i", string.char(9), { buffer = 0 })
	pcall(vim.keymap.del, "i", "<CR>")
end

-- table.pack is not in Lua 5.1 (neovim's) (it's in Lua 5.2)
local function tablePack(...)
	return { n = select("#", ...), ... }
end

local function dankPrint(opts)
	print(vim.inspect(opts))
end

function encodeString(text)
	local res = ""
	local prev_char_was_invalid = false
	for i = 1, #text do
		local ascii = text:byte(i)
		local char = text:sub(i, i)

		if ascii > 127 then
			res = res .. char
		elseif prev_char_was_invalid and char == " " then
			prev_char_was_invalid = false
		else
			prev_char_was_invalid = false
			if not prev_char_was_invalid and res ~= "" then
				res = res .. " "
			end
			local encoded = enc[char]
			res = res .. (encoded or char)
		end
	end
	return res
end

local function encodeLines(opts)
	local st = opts.line1 - 1
	local en = opts.line2 - 1
	local lines = vim.api.nvim_buf_get_lines(0, st, en + 1, false)
	for i, v in ipairs(lines) do
		lines[i] = encodeString(v)
	end
	vim.api.nvim_buf_set_lines(0, st, en + 1, false, lines)
	print("ForsEncode'd " .. (en - st + 1) .. " line(s)")
end

local function decodeLines(opts)
	print("TODO 4HEad")
end

vim.api.nvim_create_user_command("ForsEnable", addKeyMapping, { force = true })
vim.api.nvim_create_user_command("ForsDisable", removeKeyMapping, { force = true })
vim.api.nvim_create_user_command("DankPrint", dankPrint, { force = true, range = true })

vim.api.nvim_create_user_command("ForsEncode", encodeLines, { force = true, range = true })
vim.api.nvim_create_user_command("ForsDecode", decodeLines, { force = true, range = true })

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
	group = vim.api.nvim_create_augroup("forsenFtDetect", { clear = true }),
	pattern = "*.forsen",
	callback = function()
		vim.cmd([[set ft=forsen]])
	end,
})

return M
