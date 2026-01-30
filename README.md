# lazygit.nvim

Open [lazygit](https://github.com/jesseduffield/lazygit) in a fullscreen floating window inside Neovim.

## Requirements

- `lazygit` binary on `$PATH`

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "fdarian/lazygit.nvim",
  cmd = "LazyGit",
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>" },
  },
  opts = {
    -- Optional: enable vim-tmux-navigator integration
    -- https://github.com/christoomey/vim-tmux-navigator
    vim_tmux_navigator = true,
  },
}
```

## Features

- Fullscreen floating window
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) pane navigation (`Ctrl+hjkl`) — opt-in via `vim_tmux_navigator = true`
- Tab-aware layout (adjusts when Neovim tabs are open)
- Auto-resize on window change

## Credits

Inspired by previous lazygit integrations:

- [kdheepak/lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim)
