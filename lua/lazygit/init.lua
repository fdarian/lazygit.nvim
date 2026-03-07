local M = {}

local buf = nil
local win = nil
local tab = nil
local config = {}

local function set_tmux_nav_keymaps(buffer)
	local nav = {
		["<C-h>"] = "-L",
		["<C-j>"] = "-D",
		["<C-k>"] = "-U",
		["<C-l>"] = "-R",
	}
	for key, direction in pairs(nav) do
		vim.keymap.set("t", key, function()
			vim.fn.system("tmux select-pane " .. direction)
		end, { buffer = buffer })
	end
end

local function get_win_config()
	local has_tabs = #vim.api.nvim_list_tabpages() > 1
	return {
		relative = "editor",
		row = has_tabs and 1 or 0,
		col = 0,
		width = vim.o.columns,
		height = vim.o.lines - (has_tabs and 2 or 1),
		style = "minimal",
		border = "none",
	}
end

local function update_win_config()
	if win ~= nil and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_set_config(win, get_win_config())
	end
end

local function open()
	vim.cmd("tabnew")
	tab = vim.api.nvim_get_current_tabpage()

	buf = vim.api.nvim_create_buf(false, true)

	win = vim.api.nvim_open_win(buf, true, get_win_config())

	vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal", { win = win })

	vim.fn.termopen("lazygit", {
		cwd = vim.fn.getcwd(),
		on_exit = function()
			local cleanup_buf = buf
			local cleanup_win = win
			local cleanup_tab = tab
			buf = nil
			win = nil
			tab = nil

			if cleanup_win ~= nil and vim.api.nvim_win_is_valid(cleanup_win) then
				pcall(vim.api.nvim_win_close, cleanup_win, true)
			end

			if cleanup_buf ~= nil and vim.api.nvim_buf_is_valid(cleanup_buf) then
				pcall(vim.api.nvim_buf_delete, cleanup_buf, { force = true })
			end

			if cleanup_tab ~= nil and vim.api.nvim_tabpage_is_valid(cleanup_tab) then
				local tabs = vim.api.nvim_list_tabpages()
				if #tabs > 1 then
					pcall(vim.api.nvim_set_current_tabpage, cleanup_tab)
					pcall(vim.cmd, "tabclose")
				end
			end
		end,
	})

	vim.cmd("startinsert")
	if config.vim_tmux_navigator then
		set_tmux_nav_keymaps(buf)
	end
end

function M.toggle()
	if win ~= nil and vim.api.nvim_win_is_valid(win) then
		if vim.api.nvim_get_current_win() == win then
			vim.api.nvim_win_close(win, true)
			if tab ~= nil and vim.api.nvim_tabpage_is_valid(tab) then
				local tabs = vim.api.nvim_list_tabpages()
				if #tabs > 1 then
					pcall(vim.api.nvim_set_current_tabpage, tab)
					pcall(vim.cmd, "tabclose")
				end
			end
			tab = nil
		else
			if tab ~= nil and vim.api.nvim_tabpage_is_valid(tab) then
				vim.api.nvim_set_current_tabpage(tab)
			end
			vim.api.nvim_set_current_win(win)
			vim.cmd("startinsert")
		end
	else
		open()
	end
end

function M.setup(opts)
	opts = opts or {}
	config = opts

	vim.env.NVIM = vim.v.servername
	vim.env.GIT_EDITOR = "nvim"
	vim.env.EDITOR = "nvim"
	vim.env.XDG_CONFIG_HOME = "$HOME/.config"

	vim.api.nvim_create_augroup("lazygit", { clear = true })

	vim.api.nvim_create_autocmd("TabEnter", {
		group = "lazygit",
		callback = function()
			update_win_config()
			if win ~= nil and vim.api.nvim_win_is_valid(win) then
				local win_tabpage = vim.api.nvim_win_get_tabpage(win)
				local current_tabpage = vim.api.nvim_get_current_tabpage()
				if win_tabpage == current_tabpage then
					vim.api.nvim_set_current_win(win)
					vim.cmd("startinsert")
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimResized", {
		group = "lazygit",
		callback = function()
			update_win_config()
		end,
	})
end

return M
