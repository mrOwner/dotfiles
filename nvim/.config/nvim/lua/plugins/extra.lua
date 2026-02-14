return {
  -- {
  --   -- Mapping for russian language.
  --   "Wansmer/langmapper.nvim",
  --   event = "VeryLazy",
  --   enabled = false,
  --   config = true,
  -- },
  {
    -- split and join arrays or parameters of functions
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" }, -- if you install parsers with `nvim-treesitter`
    keys = {
      { "<leader>mj", "<cmd>TSJToggle<cr>", desc = "Join Toggle" },
    },
    opts = { use_default_keymaps = false, max_join_length = 120 },
  },
  { -- https://github.com/Wansmer/sibling-swap.nvim
    "Wansmer/sibling-swap.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      vim.keymap.set("n", "<leader>m,", require("sibling-swap").swap_with_left, { desc = "Swap with left" })
      vim.keymap.set("n", "<leader>m.", require("sibling-swap").swap_with_right, { desc = "Swap with right" })
    end,
  },
  {
    "famiu/bufdelete.nvim",
  },
  {
    -- which key integration
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n" },
          { "<leader>m", group = "+my" },
          { "<leader>ms", group = "Split row" },
          { "<leader>fc", group = "Copy path" },
        },
      },
    },
  },
  {
    -- isolation of buffers inside the tabs
    -- https://github.com/tiagovla/scope.nvim
    "tiagovla/scope.nvim",
    config = true,
  },
  {
    -- https://github.com/elliotxx/copypath.nvim
    "elliotxx/copypath.nvim",
    config = function()
      require("copypath").setup({
        default_mappings = false, -- Set to false to disable default mappings
        notify = true, -- Show notification when path is copied
      })
    end,
  },
  --  {
  --    -- screenshots
  --    "mistricky/codesnap.nvim",
  --    event = "VeryLazy",
  --    build = "make",
  --    config = function()
  --      require("codesnap").setup({
  --        watermark = "",
  --      })
  --    end,
  --  },
  { -- https://github.com/meznaric/key-analyzer.nvim
    -- :KeyAnalyzer <leader>
    { "meznaric/key-analyzer.nvim", opts = {} },
  },
  { -- https://github.com/hat0uma/csvview.nvim
    "hat0uma/csvview.nvim",
    config = function()
      require("csvview").setup()
      vim.keymap.set("n", "<leader>uv", require("csvview").toggle, { desc = "CSV toggle" })
    end,
  },
  {
    -- https://github.com/xzbdmw/clasp.nvim
    "xzbdmw/clasp.nvim",
    config = function()
      require("clasp").setup({
        pairs = { ["{"] = "}", ['"'] = '"', ["'"] = "'", ["("] = ")", ["["] = "]", ["<"] = ">" },
        -- If called from insert mode, do not return to normal mode.
        keep_insert_mode = true,
      })

      -- jumping from smallest region to largest region
      vim.keymap.set({ "n", "i" }, "<C-.>", function()
        require("clasp").wrap("next")
      end)

      -- jumping from largest region to smallest region
      vim.keymap.set({ "n", "i" }, "<C-,>", function()
        require("clasp").wrap("prev")
      end)

      -- -- If you want to exclude nodes whose end row is not current row
      -- vim.keymap.set({ "n", "i" }, "<c-l>", function()
      --   require("clasp").wrap("next", function(nodes)
      --     local n = {}
      --     for _, node in ipairs(nodes) do
      --       if node.end_row == vim.api.nvim_win_get_cursor(0)[1] - 1 then
      --         table.insert(n, node)
      --       end
      --     end
      --     return n
      --   end)
      -- end)
    end,
  },
  { -- https://github.com/vinnymeller/swagger-preview.nvim
    "vinnymeller/swagger-preview.nvim",
    cmd = { "SwaggerPreview", "SwaggerPreviewStop", "SwaggerPreviewToggle" },
    build = "npm i",
    config = true,
  },
  { -- https://github.com/johmsalas/text-case.nvim
    "johmsalas/text-case.nvim",
    dependencies = { "folke/which-key.nvim" },
    init = function()
      local wk = require("which-key")
      wk.add({
        mode = { "n", "v" },
        { "<leader>mc", group = "Text cases" },
      })
    end,
    config = function()
      require("textcase").setup({})
    end,
    keys = {
      {
        "<leader>mcs",
        function()
          require("textcase").current_word("to_snake_case")
        end,
        mode = { "n", "v" },
        desc = "to_snake_case",
      },
      {
        "<leader>mcd",
        function()
          require("textcase").current_word("to_dash_case")
        end,
        mode = { "n", "v" },
        desc = "to-dash-case",
      },
      {
        "<leader>mcc",
        function()
          require("textcase").current_word("to_camel_case")
        end,
        mode = { "n", "v" },
        desc = "toCamelCase",
      },
      {
        "<leader>mcp",
        function()
          require("textcase").current_word("to_pascal_case")
        end,
        mode = { "n", "v" },
        desc = "ToPascalCase",
      },
    },
    lazy = true,
  },
  -- {
  --   "m4xshen/hardtime.nvim",
  --   lazy = false,
  --   -- init = function()
  --   --   require("hardtime").setup()
  --   -- end,
  --   dependencies = { "MunifTanjim/nui.nvim" },
  --   opts = {},
  -- },
  {
    -- https://gitlab.com/itaranto/plantuml.nvim
    "https://gitlab.com/itaranto/plantuml.nvim",
    version = "*",
    config = function()
      require("plantuml").setup()
    end,
  },
  {
    -- https://github.com/mistweaverco/kulala.nvim
    "mistweaverco/kulala.nvim",
    keys = {
      { "<leader>Re", "<cmd>lua require('kulala').set_selected_env()<cr>", desc = "Change env", ft = "http" },
    },
    --   keys = {
    --     { "<leader>rs", desc = "Send request" },
    --     { "<leader>ra", desc = "Send all requests" },
    --     { "<leader>rb", desc = "Open scratchpad" },
    --   },
    --   ft = { "http", "rest" },
    --   opts = {
    --     global_keymaps = true,
    --     global_keymaps_prefix = "<leader>r",
    --     kulala_keymaps_prefix = "",
    --   },
  },
  --   {
  --     -- https://github.com/stasfilin/nvim-sandman
  --     -- Блокирует обращение других плагинов в интернет. Для работы оффлайн
  --   'stasfilin/nvim-sandman',
  --   config = function()
  --     require('nvim_sandman').setup({
  --       enabled = false,
  --       mode = 'block_all', -- block_all | blocklist | allowlist
  --     })
  --   end
  -- }
}
