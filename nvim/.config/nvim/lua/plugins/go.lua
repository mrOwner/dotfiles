return {
   -- TODO https://github.com/Allaman/nvim/blob/main/lua/core/plugins/go.lua
   {
      "ray-x/go.nvim",
      dependencies = { -- optional packages
         "ray-x/guihua.lua",
         "neovim/nvim-lspconfig",
         "nvim-treesitter/nvim-treesitter",
         "hrsh7th/cmp-nvim-lsp",
      },
      ft = { "go", "gomod" },
      event = "BufRead *.go",
      build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
      opts = {
         comment_placeholder = "",
         lsp_cfg = {
            settings = {
               gopls = {
                  hints = {
                     assignVariableTypes = false,
                     functionTypeParameters = false,
                     parameterNames = false,
                  },
               },
               golangci_lint_ls = {
                  init_options = {
                     command = {
                        "golangci-lint",
                        "run",
                        "--new",
                        "--config",
                        "~/.golangci.yaml",
                        "--out-format",
                        "json",
                     },
                  },
               },
            },
         },
         lsp_keymaps = false,
         -- dap
         dap_debug = false, -- set to false to disable dap
         dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
         -- false: do not use keymap in go/dap.lua.  you must define your own.
         dap_debug_gui = false, -- set to true to enable dap gui, highly recommended
         dap_debug_vt = false, -- set to true to enable dap virtual text

         test_runner = "go",

         diagnostic = { -- set diagnostic to false to disable vim.diagnostic setup
            virtual_text = { space = 4, prefix = "" }, -- 
         },
      },
      keys = {
         { "<M-r>", "<cmd>GoCodeLenAct<cr>", desc = "Toggle inlay hints" },

         { "<leader>cs", "<cmd>GoFillSwitch<cr>", desc = "Fill switch" },
         { "<leader>cc", "<cmd>GoCmt<cr>", desc = "Add comment" },

         { "<leader>ma", "<cmd>GoAddTag<cr>", desc = "Add tags" },
         { "<leader>mp", "<cmd>GoFixPlurals<cr>", desc = "Fix plurals" }, -- func foo(b int, a int, r int) -> func foo(b, a, r int)
         { "<leader>mj", '<cmd>["x]GoJson2Struct<cr>', desc = "Json to struct" },
         { "<leader>mi", "<cmd>GoIfErr<cr>", desc = "Gen if-err" },
         { "<leader>mr", "<cmd>GoGenReturn<cr>", desc = "Gen a return" },
         { "<leader>md", "<cmd>GoModTidy<cr>", desc = "Go mod tidy" },
         { "<leader>mv", "<cmd>GoModVendor<cr>", desc = "Go mod vendor" },
         { "<leader>mg", "<cmd>GoGet<cr>", desc = "Go get" },

         -- { "<leader>tt", "<cmd>GoTest<cr>", desc = "Test project" },
         { "<leader>tt", "<cmd>GoTestSum<cr>", desc = "Test project" },
         { "<leader>tr", "<cmd>GoTestFunc<cr>", desc = "Test func" },
         { "<leader>ts", "<cmd>GoTestFunc -s<cr>", desc = "Test func select" },
         { "<leader>tf", "<cmd>GoTestFile<cr>", desc = "Test file" },
         { "<leader>tp", "<cmd>GoTestPkg<cr>", desc = "Test pkg" },
         { "<leader>tl", "<cmd>GoLint<cr>", desc = "Lint" },
         { "<leader>tc", "<cmd>GoCoverage -p<cr>", desc = "Coverage package" },
         { "<leader>tx", "<cmd>GoCoverage -t<cr>", desc = "Coverage toggle" },
         { "<leader>tv", "<cmd>Govulncheck<cr>", desc = "Govulncheck" },
         { "<leader>too", "<cmd>GoAlt<cr>", desc = "Go to alternative" },
         { "<leader>tos", "<cmd>GoAltS<cr>", desc = "Go to alt split" },
         { "<leader>tov", "<cmd>GoAltV<cr>", desc = "Go to alt vertical" },
      },
   },
   -- -- which key integration
   {
      "folke/which-key.nvim",
      opts = {
         spec = {
            {
               mode = { "n" },
               { "<leader>tc", group = "Coverage" },
               { "<leader>to", group = "Open test" },
            },
         },
      },
   },
}
