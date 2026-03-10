return {
  {
    -- https://github.com/Exafunction/windsurf.nvim
    "Exafunction/windsurf.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- init = function()
    --   local wk = require("which-key")
    --   wk.add({
    --     mode = { "n" },
    --     { "<leader>a", group = "ai" },
    --     { "<leader>aa", "<cmd>Codeium Chat<cr>", desc = "AI Chat" },
    --   })
    -- end,
    config = function()
      require("codeium").setup({
        enable_cmp_source = false,
        virtual_text = {
          enabled = true,
          key_bindings = {
            accept = "<S-Tab>",
            accept_word = "<D-l>",
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
      })
    end,
  },
}
