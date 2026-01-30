# lazygit.nvim

Open [lazygit](https://github.com/jesseduffield/lazygit) in a fullscreen floating window inside Neovim.

## Features

- Fullscreen floating lazygit window
- [Open files from lazygit directly in Neovim](#open-files-in-neovim) — no nested editors
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) pane navigation (`Ctrl+hjkl`) — opt-in via `vim_tmux_navigator = true`

## Installation

Requirements:
- `lazygit` binary on `$PATH`

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

## Open files in Neovim

When pressing `o` on a file in lazygit, you can open it directly in the current Neovim instance instead of launching a separate editor.

Make sure [`nvr`](https://github.com/mhinz/neovim-remote) is installed, then add to `~/.config/lazygit/config.yml`:

```yaml
os:
  open: |
    noglob bash -c 'f="$1"; if [ -n "$NVIM" ]; then nvr --remote-tab-silent "$f"; else open "$f"; fi' _ {{filename}}
```

The plugin sets `$NVIM` automatically so `nvr` knows which Neovim instance to connect to. Pressing `o` in lazygit opens the file in a new Neovim tab. The `else` branch is the fallback when running lazygit outside Neovim — replace `open` with `xdg-open` on Linux.

## Credits

Inspired by previous lazygit integrations:

- [kdheepak/lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim)
