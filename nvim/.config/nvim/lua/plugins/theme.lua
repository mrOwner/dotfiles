return {
   -- {
   --    "neanias/everforest-nvim",
   --    version = false,
   --    lazy = false,
   --    priority = 1000, -- make sure to load this before all the other start plugins
   --    -- Optional; default configuration will be used if setup isn't called.
   --    config = function()
   --       require("everforest").setup({
   --          -- Your config here
   --       })
   --    end,
   -- },
   -- add everforest
   -- {
   --    "sainnhe/everforest",
   --    config = function()
   --       -- vim.g.everforest_transparent_background = 1
   --
   --       -- Для того чтобы изменения были сделаны ПОСЛЕ установки темы,
   --       -- ма устанавливаем функцию на событие User.
   --       vim.api.nvim_create_autocmd("User", {
   --          pattern = "VeryLazy",
   --          callback = function()
   --             vim.cmd([[
   --                hi NeoTreeGitUntracked gui=NONE guifg=#eebb15
   --             ]])
   --          end,
   --       })
   --    end,
   -- },
   -- -- Configure LazyVim to load everforest
   -- {
   --    "LazyVim/LazyVim",
   --    opts = {
   --       colorscheme = "everforest",
   --    },
   -- },
   -- {
   --    "folke/tokyonight.nvim",
   --    enabled = false,
   --    opts = {
   --       transparent = true,
   --       styles = {
   --          sidebars = "transparent",
   --          floats = "transparent",
   --       },
   --    },
   -- },
   {
      "rcarriga/nvim-notify",
      event = "VeryLazy",
      config = function()
         require("notify").setup({
            background_colour = "#000000",
         })
      end,
   },
}
