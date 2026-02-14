return {
  -- which key integration
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
  {
    "fang2hou/go-impl.nvim",
    ft = "go",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",

      -- Choose one of the following fuzzy finder
      "folke/snacks.nvim",
      -- "ibhagwan/fzf-lua",
    },
    keys = {
      {
        "<leader>mi",
        function()
          require("go-impl").open()
        end,
        mode = { "n" },
        desc = "Go Impl",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function()
      local golangcilint = require("lint").linters.golangcilint

      table.insert(golangcilint.args, "--new")
      table.insert(golangcilint.args, "--config=" .. vim.fn.expand("~/.golangci.yaml"))
    end,
  },
}
