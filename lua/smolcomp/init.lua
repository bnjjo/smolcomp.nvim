local M = {}
local ns = vim.api.nvim_create_namespace("smolcomp")

---@type string
vim.g.run_cmd = ""

---@return nil
local ask_for_cmd = function()
	vim.ui.input({ prompt = "compile command: ", default = vim.g.run_cmd }, function(cmd)
		if cmd ~= "" and cmd ~= nil then
			vim.g.run_cmd = cmd
		else
			vim.g.run_cmd = ""
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
	vim.api.nvim_set_current_buf(buf)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("filetype", "compilation", { buf = buf })
	return buf
end

-- highlight and display final message based on exit code
---@param bufnr integer
---@return nil
local print_final_msg = function(bufnr)
	local msg = "finished successfully at " .. os.date()
	local color = "DiagnosticOk" -- green
	local fin = 33 -- highlight `finished succeessfully`
	if vim.v.shell_error ~= 0 then
		msg = "failed with exit code " .. vim.v.shell_error
		color = "DiagnosticError" -- red
		fin = 19 -- highlight `failed`
	end
	vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { -- append to end
		"",
		"compilation " .. msg,
	})

	local last_line = vim.api.nvim_buf_line_count(bufnr) - 1
	vim.hl.range(bufnr, ns, color, { last_line, 12 }, { last_line, fin })
end

---@return integer|nil
local new_tab_run = function()
	ask_for_cmd()
	if vim.g.run_cmd ~= "" then
		local bufnr = open_new_tab()
		local welcome = {
			"cmd: " .. vim.g.run_cmd,
			"compilation started at " .. os.date(),
			" ",
			" ",
		}
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, welcome)
		vim.api.nvim_win_set_cursor(0, { 4, 0 })
		exec_cmd(vim.g.run_cmd)
		print_final_msg(bufnr)
		return bufnr
	else
		print("compilation aborted, no command provided.")
		return nil
	end
end

vim.keymap.set("n", "<leader>cp", function()
	local bufnr = new_tab_run()
	vim.bo[bufnr].readonly = true
	vim.bo[bufnr].modifiable = false
end)
-- vim.keymap.set("n", "<ESC>", function()
--     -- TODO: hondle closing the tab + buffer with escape
-- end)

return M
