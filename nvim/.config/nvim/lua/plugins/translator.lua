return {
   {
      "potamides/pantran.nvim",
      cmd = "Pantran",
      keys = {
         {
            mode = "n",
            "<leader>mt",
            function()
               local pantran = require("pantran")
               return pantran.motion_translate()
            end,
            desc = "+Translate",
            remap = true,
            silent = true,
            expr = true,
         },
         {
            mode = "n",
            "<leader>mtt",
            function()
               local pantran = require("pantran")
               return pantran.motion_translate() .. "_"
            end,
            desc = "Translate",
            remap = true,
            silent = true,
            expr = true,
         },
         {
            mode = "x",
            "<leader>mt",
            -- ":Pantran motion_translate<CR>",
            function()
               local pantran = require("pantran")
               return pantran.motion_translate()
            end,
            desc = "Translate",
            remap = true,
            silent = true,
            expr = true,
         },
      },
      opts = {
         default_engine = "yandex",
         command = {
            default_mode = "hover",
         },
         engines = {
            yandex = {
               fallback = {
                  default_source = "en",
                  default_target = "ru",
               },
            },
         },
      },
   },
}
