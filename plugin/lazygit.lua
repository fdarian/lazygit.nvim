vim.api.nvim_create_user_command("LazyGit", function()
	require("lazygit").toggle()
end, {})