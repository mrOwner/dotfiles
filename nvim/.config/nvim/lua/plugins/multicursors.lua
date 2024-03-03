return {
   "brenton-leighton/multiple-cursors.nvim",
   opts = {
      enable_split_paste = false,
      -- disabled_default_key_maps = {
      --    { { "n", "x" }, { "<S-Left>", "<S-Right>" } },
      -- },
      -- custom_key_maps = {
      --    {
      --       { "n", "i" },
      --       "<C-/>",
      --       function()
      --          vim.cmd("ExampleCommand")
      --       end,
      --    },
      -- },
      -- pre_hook = function()
      --    vim.print("Hello")
      -- end,
      -- post_hook = function()
      --    vim.print("Goodbye")
      -- end,
   },
   keys = {
      { "<S-Down>", "<Cmd>MultipleCursorsAddDown<CR>", mode = { "n", "i" } },
      -- { "<S-j>", "<Cmd>MultipleCursorsAddDown<CR>" },
      { "<S-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = { "n", "i" } },
      -- { "<S-k>", "<Cmd>MultipleCursorsAddUp<CR>" },
      { "<S-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = { "n", "i" } },
   },
}
