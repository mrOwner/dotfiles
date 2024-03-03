return {
   {
      -- Mapping for russian language.
      "Wansmer/langmapper.nvim",
      event = "VeryLazy",
      enabled = false,
      config = true,
   },
   {
      -- which key integration
      "folke/which-key.nvim",
      opts = {
         defaults = {
            ["<leader>m"] = { name = "+my" },
            ["<leader>ms"] = { name = "Split row" },
            ["<leader>fc"] = { name = "Copy path" },
         },
      },
   },
}
