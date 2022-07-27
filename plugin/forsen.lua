local M = {}

local lib = require("forsencode.lib")
local enc = lib.encTable

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

local function encodeLines(opts)
	local st = opts.line1 - 1
	local en = opts.line2 - 1
	local lines = vim.api.nvim_buf_get_lines(0, st, en + 1, false)
	for i, v in ipairs(lines) do
		lines[i] = lib.encodeString(v)
	end
	vim.api.nvim_buf_set_lines(0, st, en + 1, false, lines)
	print("ForsEncode'd " .. (en - st + 1) .. " line(s)")
end

local function decodeLines(opts)
	local st = opts.line1 - 1
	local en = opts.line2 - 1
	local lines = vim.api.nvim_buf_get_lines(0, st, en + 1, false)
	for i, v in ipairs(lines) do
		lines[i] = lib.decodeString(v)
	end
	vim.api.nvim_buf_set_lines(0, st, en + 1, false, lines)
	print("ForsDecoded'd " .. (en - st + 1) .. " line(s)")
end

vim.api.nvim_create_user_command("ForsEnable", addKeyMapping, { force = true })
vim.api.nvim_create_user_command("ForsDisable", removeKeyMapping, { force = true })
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
