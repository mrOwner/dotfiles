return {
   {
      "hrsh7th/nvim-cmp",
      ---@param opts cmp.ConfigSchema
      opts = function(_, opts)
         local cmp = require("cmp")
         local luasnip = require("luasnip")

         opts.mapping = cmp.mapping.preset.insert({
            ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-u>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            -- ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            -- ["<Tab>"] = cmp.mapping.confirm({ select = true }),
            ["<S-CR>"] = cmp.mapping.confirm({
               behavior = cmp.ConfirmBehavior.Replace,
               select = true,
            }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            ["<C-CR>"] = function(fallback)
               cmp.abort()
               fallback()
            end,
            ["<Tab>"] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  -- cmp.select_next_item()
                  cmp.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert })
               elseif luasnip.jumpable(1) then
                  luasnip.jump(1)
               else
                  fallback()
               end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  cmp.select_prev_item()
               elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
               else
                  fallback()
               end
            end, { "i", "s" }),
         })
         opts.experimental = {
            ghost_text = false,
         }
      end,
   },
   {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
   },
}
