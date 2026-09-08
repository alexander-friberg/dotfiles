vim.pack.add {
  { src = 'https://github.com/scottmckendry/cyberdream.nvim' },
  { src = 'https://github.com/sainnhe/everforest' },
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/ellisonleao/gruvbox.nvim"},
}

require('cyberdream').setup {
  transparent = true,
  styles = {
	  comments = {italics = false},
  },
}

vim.g.everforest_transparent_background = 2
vim.g.everforest_disable_italic_comment = 1
vim.g.everforest_ui_contrast = "high"
vim.g.everforest_diagnostic_line_highlight = 1
vim.g.everforest_diagnostic_virtual_text = 'colored'

require("catppuccin").setup({
  flavor = "mocha",
  transparent_background = true,
  no_italic = true,
  no_bold = true,
})

require("gruvbox").setup({
  transparent_mode = true,
  contrast = "hard",
})
vim.o.background = "light"
vim.cmd.colorscheme 'gruvbox'
