local M = {}

vim.api.nvim_set_hl(0, 'TermFloatNormal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'TermFloatBorder', { fg = '#859289', bg = 'NONE' })

local term_buf = nil
local term_win = nil

local function open_win()
  local total_w = math.floor(vim.o.columns * 0.8)
  local total_h = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - total_h) / 2)
  local col = math.floor((vim.o.columns - total_w) / 2)

  local is_new = not (term_buf and vim.api.nvim_buf_is_valid(term_buf))
  if is_new then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  term_win = vim.api.nvim_open_win(term_buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = total_w,
    height = total_h,
    border = 'rounded',
    style = 'minimal',
  })
  vim.wo[term_win].winhighlight = 'NormalFloat:TermFloatNormal,FloatBorder:TermFloatBorder'

  if is_new then
    vim.fn.termopen(vim.o.shell)
  end
  vim.cmd.startinsert()
end

local function toggle()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
  else
    open_win()
  end
end

M.toggle = toggle

vim.keymap.set({ 'n', 't' }, '<leader>tt', toggle, { desc = '[T]oggle floating [t]erminal' })

return M
