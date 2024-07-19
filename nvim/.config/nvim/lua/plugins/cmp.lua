return {
   "nvim-cmp",
   ---@param opts cmp.ConfigSchema
   opts = function(_, opts)
      local cmp = require("cmp")

      opts.mapping["<Tab>"] = cmp.mapping.confirm({ select = true })
      opts.mapping["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert })
      opts.mapping["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
      opts.mapping["<C-u>"] = cmp.mapping.scroll_docs(4)
      opts.mapping["<C-d>"] = cmp.mapping.scroll_docs(-4)
      opts.experimental.ghost_text = false
   end,
}
