vim.pack.add({
  "https://github.com/folke/snacks.nvim",
})

require("snacks").setup({
  dashboard = {
    enabled = true,

    preset = {
      header = [[
 _____   ______        ______           _____     ____      ____  ____      ______  _______   
│╲    ╲ │╲     ╲   ___│╲     ╲     ____│╲    ╲   │    │    │    ││    │    │      ╲╱       ╲  
 ╲╲    ╲│ ╲     ╲ │     ╲     ╲   ╱     ╱╲    ╲  │    │    │    ││    │   ╱          ╱╲     ╲ 
  ╲│    ╲  ╲     ││     ,_____╱│ ╱     ╱  ╲    ╲ │    │    │    ││    │  ╱     ╱╲   ╱ ╱╲     │
   │     ╲  │    ││     ╲──'╲_│╱│     │    │    ││    │    │    ││    │ ╱     ╱╲ ╲_╱ ╱ ╱    ╱│
   │      ╲ │    ││     ╱___╱│  │     │    │    ││    │    │    ││    ││     │  ╲│_│╱ ╱    ╱ │
   │    │╲ ╲│    ││     ╲____│╲ │╲     ╲  ╱    ╱││╲    ╲  ╱    ╱││    ││     │       │    │  │
   │____││╲_____╱││____ '     ╱││ ╲_____╲╱____╱ ││ ╲ ___╲╱___ ╱ ││____││╲____╲       │____│  ╱
   │    │╱ ╲│   │││    ╱_____╱ │ ╲ │    ││    │ ╱ ╲ │   ││   │ ╱ │    ││ │    │      │    │ ╱ 
   │____│   │___│╱│____│     │ ╱  ╲│____││____│╱   ╲│___││___│╱  │____│ ╲│____│      │____│╱  
                       │_____│╱                                                               
vi . vim . nvim
                                                             ]],
      keys = {
        { icon = "> ", key = "f", desc = "[ Find File ]", action = ":Telescope find_files" },
        { icon = "> ", key = "r", desc = "[ Recent Files ]", action = ":Telescope oldfiles" },
        { icon = "> ", key = "p", desc = "[ Projects ]", action = ":lua Snacks.picker.projects()" },
        { icon = "> ", key = "n", desc = "[ New File ]", action = ":ene | startinsert" },
        { icon = "> ", key = "q", desc = "[ Quit ]", action = ":qa" },
      },
    },

    sections = {
      {
        section = "header",
      },
      {
        section = "keys",
        gap = 1,
        padding = 1,
      },
    },
  },
})
