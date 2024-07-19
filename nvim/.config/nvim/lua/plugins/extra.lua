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
      -- Auto close buffers
      "axkirillov/hbac.nvim",
      config = true,
   },
   {
      "mistricky/codesnap.nvim",
      build = "make",
      config = function()
         require("codesnap").setup({
            watermark = "",
         })
      end,
   },
}
