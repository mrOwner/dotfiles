return {
  {
    -- https://github.com/folke/snacks.nvim
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>'",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume",
      },
      {
        "<leader>*",
        function()
          Snacks.picker.grep_word()
        end,
        desc = "Visual selection or word",
        mode = { "n", "x" },
      },
      opts = {
        picker = {
          win = {
            input = {
              keys = {
                ["<a-o>"] = { "toggle_hidden", mode = { "i", "n" } },
              },
            },
          },
        },
      },
    },
  },
  {
    -- https://github.com/folke/todo-comments.nvim
    "folke/todo-comments.nvim",
    opts = {
      -- keywords = {
      --   FIX = {
      --     icon = " ", -- icon used for the sign, and in search results
      --     color = "error", -- can be a hex color, or a named color (see below)
      --     alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
      --     -- signs = false, -- configure signs for some keywords individually
      --   },
      --   TODO = { icon = " ", color = "info" },
      --   HACK = { icon = " ", color = "warning" },
      --   WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
      --   PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
      --   NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
      --   TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      -- },
      highlight = {
        -- pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        -- Highlight any TODO or TODO(foo):
        pattern = [[.*<((KEYWORDS\s?)\s?(\(.*\))?):]],
      },
      search = {
        -- pattern = [[\b(KEYWORDS):]], -- ripgrep regex
        -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
        pattern = [[\b((KEYWORDS)(\(.*\))?):]],
      },
    },
  },
}
