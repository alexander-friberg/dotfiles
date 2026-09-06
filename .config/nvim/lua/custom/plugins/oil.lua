vim.pack.add {
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
}

-- default_file_explorer normally disables netrw too; since we're setting it
-- false below (oilfloat.lua's VimEnter hook is the entry point for `nvim .`
-- instead), disable netrw ourselves so it doesn't render its own listing
-- behind the float.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('oil').setup {
  -- oilfloat.lua's VimEnter hook is the entry point for directory args
  -- (e.g. `nvim .`) instead; leave this false so oil doesn't also try to
  -- convert the same buffer into its normal inline listing.
  default_file_explorer = false,
  columns = { 'icon' },
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ['<C-h>'] = false,
    ['<C-l>'] = false,
  },
}

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
