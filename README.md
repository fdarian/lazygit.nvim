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
  opts = {},
}
```

## Features

- Fullscreen floating window
- Tmux pane navigation (`Ctrl+hjkl`)
- Tab-aware layout (adjusts when Neovim tabs are open)
- Auto-resize on window change
