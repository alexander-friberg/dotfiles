-- Statuscolumn: the cursor line's absolute number is pushed right, toward
-- the text; every other line's relative number is pushed left, toward the
-- sign column.
local M = {}

function M.get()
  local lnum = vim.v.lnum
  local relnum = vim.v.relnum
  local virtnum = vim.v.virtnum

  -- Don't number virtual/wrapped lines (e.g. multi-line diagnostics).
  if virtnum ~= 0 then
    return '%s'
  end

  if relnum == 0 then
    return '%s%=' .. lnum .. ' '
  else
    return '%s ' .. relnum .. '%='
  end
end

return M
