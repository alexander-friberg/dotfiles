-- [[Godot]]

-- Starts a named pipe server so Godot can open files in this Neovim instance.
-- Checks cwd and parent dir for a project.godot file.
local function start_godot_server()
  local paths_to_check = { '', '/..' }
  local cwd = vim.fn.getcwd()
  for _, value in pairs(paths_to_check) do
    local project_file = cwd .. value .. '/project.godot'
    if vim.uv.fs_stat(project_file) then
      local godot_project_path = cwd .. value
      local pipe_path = godot_project_path .. '/server.pipe'
      if not vim.uv.fs_stat(pipe_path) then vim.fn.serverstart(pipe_path) end
      break
    end
  end
end

start_godot_server()

vim.api.nvim_create_autocmd({ 'DirChanged', 'BufReadPost' }, {
  callback = start_godot_server,
})

-- Connects to Godot's built-in LSP server for GDScript autocomplete/diagnostics.
-- Make sure Godot is running and the port matches:
-- Editor Settings → Network → Language Server Port (default: 6005)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gdscript',
  callback = function()
    vim.lsp.start({
      name = 'godot',
      cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
    })
  end,
})
