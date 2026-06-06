local M = {}

local ns = vim.api.nvim_create_namespace("smolcomp")

---@type string
vim.g.comp_cmd = ""

---@return nil
local ask_for_cmd = function()
	vim.ui.input({ prompt = "compile command: ", default = vim.g.comp_cmd }, function(cmd)
		if cmd ~= "" and cmd ~= nil then
			vim.g.comp_cmd = cmd
		else
			vim.g.comp_cmd = ""
		end
	end)
end

---@param cmd string
---@return nil
local exec_cmd = function(cmd)
	-- silent! supresses any shell errors
	-- . dumps the output to the current buffer
	-- ! executes the following command as a shell command
	vim.cmd("silent! :.!" .. cmd)
end

---@return integer
local function open_new_tab()
	vim.cmd("tabnew")
	local buf = vim.api.nvim_create_buf(true, true)
	vim.bo[buf].readonly = true
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("filetype", "compilation", { buf = buf })
	return buf
end

---@return nil
local new_tab_compile = function()
	ask_for_cmd()
	if vim.g.comp_cmd ~= "" then
		local bufnr = open_new_tab()
		local welcome = {
			"cmd: " .. vim.g.comp_cmd,
			"compilation started at " .. os.date(),
			" ",
			" ",
		}
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, welcome)
		vim.api.nvim_win_set_cursor(0, { 4, 0 })
		exec_cmd(vim.g.comp_cmd)
		local msg = "finished successfully at " .. os.date()
		local color = "DiagnosticOk"
		local fin = 33
		if vim.v.shell_error ~= 0 then
			msg = "failed with exit code " .. vim.v.shell_error
			color = "DiagnosticError"
			fin = 19
		end
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { -- append to end
			"",
			"compilation " .. msg,
		})
		local last_line = vim.api.nvim_buf_line_count(bufnr) - 1
		vim.hl.range(bufnr, ns, color, { last_line, 12 }, { last_line, fin })
	else
		print("compilation aborted, no command provided.")
	end
end

vim.keymap.set("n", "<leader>cp", function()
	new_tab_compile()
end)
-- vim.keymap.set("n", "<ESC>", function()
--     -- TODO: hondle closing the tab + buffer with escape
-- end)

return M
