local M = {}

local buf = nil
local win = nil
local tab = nil
local tab_autocmd = nil
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

local function create_float(target_buf)
	win = vim.api.nvim_open_win(target_buf, true, get_win_config())
	vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal", { win = win })
end

local function cleanup()
	if tab_autocmd ~= nil then
		pcall(vim.api.nvim_del_autocmd, tab_autocmd)
		tab_autocmd = nil
	end

	if win ~= nil and vim.api.nvim_win_is_valid(win) then
		pcall(vim.api.nvim_win_close, win, true)
	end
	win = nil

	if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
	end
	buf = nil

	local cleanup_tab = tab
	tab = nil

	if cleanup_tab ~= nil and vim.api.nvim_tabpage_is_valid(cleanup_tab) then
		local tabs = vim.api.nvim_list_tabpages()
		if #tabs > 1 then
			pcall(vim.api.nvim_set_current_tabpage, cleanup_tab)
			pcall(vim.cmd, "tabclose")
		end
	end
end

local function move_to_dedicated_tab()
	local file_tab = vim.api.nvim_get_current_tabpage()

	if win ~= nil and vim.api.nvim_win_is_valid(win) then
		pcall(vim.api.nvim_win_close, win, true)
		win = nil
	end

	vim.cmd("tabnew")
	tab = vim.api.nvim_get_current_tabpage()

	create_float(buf)

	vim.api.nvim_set_current_tabpage(file_tab)
end

local function open()
	buf = vim.api.nvim_create_buf(false, true)

	create_float(buf)

	vim.fn.termopen("lazygit", {
		cwd = vim.fn.getcwd(),
		on_exit = function()
			cleanup()
		end,
	})

	vim.cmd("startinsert")
	if config.vim_tmux_navigator then
		set_tmux_nav_keymaps(buf)
	end

	tab_autocmd = vim.api.nvim_create_autocmd("TabNewEntered", {
		group = "lazygit",
		callback = function()
			if tab ~= nil or win == nil then
				return
			end

			if tab_autocmd ~= nil then
				pcall(vim.api.nvim_del_autocmd, tab_autocmd)
				tab_autocmd = nil
			end

			move_to_dedicated_tab()
		end,
	})
end

function M.toggle()
	if win ~= nil and vim.api.nvim_win_is_valid(win) then
		if vim.api.nvim_get_current_win() == win then
			vim.api.nvim_win_close(win, true)
			win = nil
			-- If on a dedicated tab, switch away (keep tab alive for re-show)
			if tab ~= nil and vim.api.nvim_tabpage_is_valid(tab) then
				local tabs = vim.api.nvim_list_tabpages()
				for i, t in ipairs(tabs) do
					if t == tab then
						local target_idx = i > 1 and i - 1 or i + 1
						if target_idx <= #tabs then
							vim.api.nvim_set_current_tabpage(tabs[target_idx])
						end
						break
					end
				end
			end
		else
			if tab ~= nil and vim.api.nvim_tabpage_is_valid(tab) then
				vim.api.nvim_set_current_tabpage(tab)
			end
			vim.api.nvim_set_current_win(win)
			vim.cmd("startinsert")
		end
	elseif buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
		if tab ~= nil and vim.api.nvim_tabpage_is_valid(tab) then
			vim.api.nvim_set_current_tabpage(tab)
		end
		create_float(buf)
		vim.cmd("startinsert")
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
