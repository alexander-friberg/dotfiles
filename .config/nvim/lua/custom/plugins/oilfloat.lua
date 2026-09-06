local M = {}

local augroup = vim.api.nvim_create_augroup('OilFloatPreview', { clear = true })

-- Pinned explicitly (instead of linking to NormalFloat/FloatBorder) so the
-- picker's background is deterministic regardless of what the colorscheme
-- does with floats. bg = 'NONE' lets the terminal's own background show
-- through (true transparency); swap in '#000000' for solid black instead.
vim.api.nvim_set_hl(0, 'OilFloatNormal', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'OilFloatBorder', { fg = '#859289', bg = 'NONE' })

local function close_floats(oil_win, preview_win, origin_win)
  vim.api.nvim_clear_autocmds { group = augroup }
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
  end
  if oil_win and vim.api.nvim_win_is_valid(oil_win) then
    vim.api.nvim_win_close(oil_win, true)
  end
  if origin_win and vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
    -- If we launched on a raw directory buffer (e.g. `nvim .` at startup)
    -- and the user cancelled without picking a file, that buffer is an
    -- unconverted directory buffer, not something worth showing. Swap it
    -- for a blank scratch buffer instead.
    local obuf = vim.api.nvim_win_get_buf(origin_win)
    local oname = vim.api.nvim_buf_get_name(obuf)
    if oname ~= '' and vim.fn.isdirectory(oname) == 1 then
      vim.cmd.enew()
    end
  end
end

function M.open(dir)
  local origin_win = vim.api.nvim_get_current_win()
  local start_dir = dir or vim.fn.expand '%:p:h'
  if start_dir == '' then
    start_dir = vim.fn.getcwd()
  end

  local total_w = math.floor(vim.o.columns * 0.8)
  local total_h = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - total_h) / 2)
  local col = math.floor((vim.o.columns - total_w) / 2)
  local left_w = math.floor(total_w * 0.35)
  local right_w = total_w - left_w - 2

  require('oil').open_float(start_dir)
  local oil_win = vim.api.nvim_get_current_win()

  vim.api.nvim_win_set_config(oil_win, {
    relative = 'editor',
    row = row,
    col = col,
    width = left_w,
    height = total_h,
    border = 'rounded',
  })
  vim.wo[oil_win].winhighlight = 'NormalFloat:OilFloatNormal,FloatBorder:OilFloatBorder'

  local preview_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[preview_buf].bufhidden = 'wipe'
  local preview_win = vim.api.nvim_open_win(preview_buf, false, {
    relative = 'editor',
    row = row,
    col = col + left_w + 2,
    width = right_w,
    height = total_h,
    border = 'rounded',
    style = 'minimal',
    focusable = false,
  })
  vim.wo[preview_win].winhighlight = 'NormalFloat:OilFloatNormal,FloatBorder:OilFloatBorder'

  vim.api.nvim_set_current_win(oil_win)

  local function update_preview()
    if not vim.api.nvim_buf_is_valid(preview_buf) then
      return
    end
    local entry = require('oil').get_cursor_entry()
    local dir = require('oil').get_current_dir()
    vim.bo[preview_buf].modifiable = true
    if entry and entry.type == 'file' and dir then
      local path = dir .. entry.name
      if vim.fn.filereadable(path) == 1 then
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, vim.fn.readfile(path, '', 1000))
        vim.bo[preview_buf].filetype = vim.filetype.match { filename = path } or ''
      else
        vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})
      end
    else
      vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, {})
    end
    vim.bo[preview_buf].modifiable = false
  end

  local function select_file()
    local entry = require('oil').get_cursor_entry()
    local dir = require('oil').get_current_dir()
    if entry and entry.type ~= 'directory' and dir then
      local path = dir .. entry.name
      close_floats(oil_win, preview_win, origin_win)
      vim.cmd.edit(vim.fn.fnameescape(path))
    else
      require('oil.actions').select.callback()
    end
  end

  local function cancel()
    close_floats(oil_win, preview_win, origin_win)
  end

  -- oil swaps in a fresh buffer per directory (and lists it asynchronously),
  -- so keymaps/preview are (re)bound to whatever buffer currently occupies
  -- oil_win rather than to a fixed buffer number captured at open time.
  local function bind_keymaps(buf)
    vim.keymap.set('n', '<CR>', select_file, { buffer = buf, desc = 'Oil float: select' })
    vim.keymap.set('n', 'q', cancel, { buffer = buf, desc = 'Oil float: cancel' })
    vim.keymap.set('n', '<Esc>', cancel, { buffer = buf, desc = 'Oil float: cancel' })
  end

  bind_keymaps(vim.api.nvim_get_current_buf())
  vim.schedule(update_preview)

  vim.api.nvim_create_autocmd('CursorMoved', {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == oil_win then
        update_preview()
      end
    end,
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = function(args)
      if vim.api.nvim_get_current_win() == oil_win then
        bind_keymaps(args.buf)
        vim.schedule(update_preview)
      end
    end,
  })

  vim.api.nvim_create_autocmd('WinClosed', {
    group = augroup,
    callback = function(args)
      local closed_win = tonumber(args.match)
      if closed_win == oil_win or closed_win == preview_win then
        close_floats(oil_win, preview_win, nil)
      end
    end,
  })
end

vim.keymap.set('n', '<leader>o', M.open, { desc = 'Oil file picker (float)' })

-- Make the float the entry point for `nvim <dir>` (e.g. `nvim .`) instead
-- of oil's normal inline buffer. Requires default_file_explorer = false in
-- oil.lua so oil doesn't also try to hijack the same directory buffer.
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('OilFloatStartup', { clear = true }),
  nested = true,
  callback = function()
    if vim.fn.argc() ~= 1 then
      return
    end
    local path = vim.fn.fnamemodify(vim.fn.argv(0), ':p')
    if vim.fn.isdirectory(path) == 1 then
      vim.schedule(function()
        M.open(path)
      end)
    end
  end,
})

return M
