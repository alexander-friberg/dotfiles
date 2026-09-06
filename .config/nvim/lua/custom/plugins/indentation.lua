-- Per-filetype indent width defaults.
-- Fires on FileType, which happens before guess-indent.nvim's BufReadPost
-- hook and before built-in editorconfig applies b:editorconfig — so this
-- only sets a language-appropriate *default*; guess-indent or a project's
-- .editorconfig can still override it for that specific buffer.
local indent_by_filetype = {
  python = { shiftwidth = 4, tabstop = 4, softtabstop = 4, expandtab = true },
  go = { shiftwidth = 4, tabstop = 4, softtabstop = 4, expandtab = false }, -- gofmt uses tabs
  make = { expandtab = false }, -- Makefiles require literal tabs
}

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('custom-indentation', { clear = true }),
  pattern = vim.tbl_keys(indent_by_filetype),
  callback = function(args)
    local opts = indent_by_filetype[vim.bo[args.buf].filetype]
    if not opts then return end
    for k, v in pairs(opts) do
      vim.bo[args.buf][k] = v
    end
  end,
})
