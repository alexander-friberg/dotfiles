-- Neogit: Magit-inspired git interface for Neovim
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/sindrets/diffview.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/NeogitOrg/neogit" },
})

local neogit = require("neogit")

neogit.setup({
  kind = "tab", -- open Neogit in its own tab, "split" and "floating" also work
  integrations = {
    diffview = true, -- adds 'd' to open diffview from the status buffer
  },
  commit_editor = {
    kind = "split",
  },
  console_timeout = 2000,
  auto_refresh = true,
})

-- Keymaps
vim.keymap.set("n", "<leader>gg", neogit.open, { desc = "Open Neogit" })
vim.keymap.set("n", "<leader>gc", function()
  neogit.open({ "commit" })
end, { desc = "Neogit commit" })
vim.keymap.set("n", "<leader>gp", function()
  neogit.open({ "pull" })
end, { desc = "Neogit pull" })
vim.keymap.set("n", "<leader>gP", function()
  neogit.open({ "push" })
end, { desc = "Neogit push" })
