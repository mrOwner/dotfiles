return {
   "saghen/blink.cmp",
   ---@module 'blink.cmp'
   ---@type blink.cmp.Config
   opts = {
      keymap = {
         preset = "super-tab",
         -- ["<C-y>"] = { "select_and_accept" },
         ["<C-k>"] = { "select_prev", "fallback" },
         ["<C-j>"] = { "select_next", "fallback" },
         ["<C-u>"] = { "scroll_documentation_up", "fallback" },
         ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      },
   },
}
