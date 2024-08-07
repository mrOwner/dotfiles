return {
   "Exafunction/codeium.vim",
   config = function()
      require("codeium").setup({
         enable_chat = true,
      })

      vim.g.codeium_idle_delay = 5
      vim.g.codeium_disable_bindings = 1

      vim.keymap.set("i", "<S-Tab>", function()
         -- vim.api.nvim_input(vim.fn["codeium#Accept"]())
         return vim.fn["codeium#Accept"]()
      end, { expr = true })
      vim.keymap.set("i", "<c-;>", function()
         return vim.fn["codeium#CycleCompletions"](1)
      end, { expr = true })
      vim.keymap.set("i", "<c-,>", function()
         return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true })
      vim.keymap.set("i", "<c-x>", function()
         return vim.fn["codeium#Clear"]()
      end, { expr = true })
   end,
}
