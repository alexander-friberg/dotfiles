vim.pack.add { { src = 'https://github.com/brenoprata10/nvim-highlight-colors' } }

require('nvim-highlight-colors').setup {
  render = 'background',
  enable_tailwind = true,
}
