return {
  -- I could not get this to work
  -- {
  --   "folke/snacks.nvim",
  --   priority = 1000,
  --   lazy = false,
  --   ---@type snacks.Config
  --   keys = {
  --     {
  --       "<leader>N",
  --       function()
  --         Snacks.picker.notifications()
  --       end,
  --       desc = "Notification History",
  --     },
  --   },
  -- },
  {
    "Hashino/doing.nvim",
    init = function()
      local wk = require("which-key")
      wk.add({
        mode = { "n" },
        { "<leader>mn", group = "ToDos" },
      })
    end,
    cmd = "Do",
    keys = {
      {
        "<leader>mna",
        function()
          require("doing").add()
        end,
        {},
        desc = "Add new task",
      },
      {
        "<leader>mnn",
        function()
          require("doing").done()
        end,
        {},
        desc = "Mark task as done",
      },
      {
        "<leader>mne",
        function()
          require("doing").edit()
        end,
        {},
        desc = "Edit task",
      },
    },
  },
}
