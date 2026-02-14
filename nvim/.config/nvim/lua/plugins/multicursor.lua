return {
  {
    -- https://github.com/jake-stewart/multicursor.nvim
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    init = function()
      local wk = require("which-key")
      wk.add({
        mode = { "n", "x" },
        { "<leader>i", group = "multicursor" },
      })
    end,
    keys = {
      {
        "<S-Down>",
        function()
          require("multicursor-nvim").lineAddCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Multicursor down",
      },
      {
        "<S-Up>",
        function()
          require("multicursor-nvim").lineAddCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Multicursor up",
      },
      -- Add or skip adding a new cursor by matching word/selection
      {
        "<leader>j",
        function()
          require("multicursor-nvim").matchAddCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Multicursor match down",
      },
      {
        "<leader>J",
        function()
          require("multicursor-nvim").matchSkipCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Multicursor match down",
      },
      {
        "<leader>k",
        function()
          require("multicursor-nvim").matchAddCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Multicursor match up",
      },
      {
        "<leader>K",
        function()
          require("multicursor-nvim").matchSkipCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Multicursor match up",
      },
      -- Enable/disable cursors
      {
        "<C-q>",
        function()
          require("multicursor-nvim").toggleCursor()
        end,
        mode = { "n", "x" },
        desc = "Toggle multicursor",
      },
      -- Mouse support
      {
        "<C-LeftMouse>",
        function()
          require("multicursor-nvim").handleMouse()
        end,
        mode = "n",
        desc = "Multicursor mouse click",
      },
      {
        "<C-LeftDrag>",
        function()
          require("multicursor-nvim").handleMouseDrag()
        end,
        mode = "n",
        desc = "Multicursor mouse drag",
      },
      {
        "<C-LeftRelease>",
        function()
          require("multicursor-nvim").handleMouseRelease()
        end,
        mode = "n",
        desc = "Multicursor mouse release",
      },
      {
        "<leader>ia",
        function()
          require("multicursor-nvim").matchAllAddCursors()
        end,
        mode = { "n", "x" },
        desc = "Match all",
      },
      {
        "<leader>i/",
        function()
          require("multicursor-nvim").searchAllAddCursors()
        end,
        mode = { "n", "x" },
        desc = "Search all",
      },
      {
        "<leader>in",
        function()
          require("multicursor-nvim").searchAddCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Search forward",
      },
      {
        "<leader>iN",
        function()
          require("multicursor-nvim").searchAddCursor(-1)
        end,
        mode = { "n", "x" },
        desc = "Search backward",
      },
      {
        "<leader>id",
        function()
          require("multicursor-nvim").diagnosticAddCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Diagnostic forward",
      },
      {
        "<leader>iD",
        function()
          require("multicursor-nvim").diagnosticSkipCursor(1)
        end,
        mode = { "n", "x" },
        desc = "Diagnostic skip",
      },
      {
        "<leader>iw",
        function()
          require("multicursor-nvim").diagnosticMatchCursors({ severity = vim.diagnostic.severity.WARN })
        end,
        mode = { "n", "x" },
        desc = "Diagnostic range",
      },
      {
        "<leader>ie",
        function()
          -- See `:h vim.diagnostic.GetOpts`.
          require("multicursor-nvim").diagnosticMatchCursors({ severity = vim.diagnostic.severity.ERROR })
        end,
        mode = { "n", "x" },
        desc = "Error range",
      },
      {
        "<leader>igv",
        function()
          require("multicursor-nvim").restoreCursors()
        end,
        mode = { "n" },
        desc = "Restore range",
      },
      {
        "<leader>it",
        function()
          require("multicursor-nvim").transposeCursors(1)
        end,
        mode = { "x" },
        desc = "Rotate text forward",
      },
      {
        "<leader>iT",
        function()
          require("multicursor-nvim").transposeCursors(-1)
        end,
        mode = { "x" },
        desc = "Rotate text backward",
      },
      {
        "<leader>im",
        function()
          require("multicursor-nvim").operator()
        end,
        mode = { "n", "x" },
        desc = "Multicursor operator",
      },
    },
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      -- Mappings defined in a keymap layer only apply when there are
      -- multiple cursors. This lets you have overlapping mappings.
      mc.addKeymapLayer(function(layerSet)
        -- Select a different cursor as the main one.
        layerSet({ "n", "x" }, "<left>", mc.prevCursor)
        layerSet({ "n", "x" }, "<right>", mc.nextCursor)

        -- Delete the main cursor.
        -- layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, "MultiCursorCursor", { reverse = true })
      hl(0, "MultiCursorVisual", { link = "Visual" })
      hl(0, "MultiCursorSign", { link = "SignColumn" })
      hl(0, "MultiCursorMatchPreview", { link = "Search" })
      hl(0, "MultiCursorDisabledCursor", { reverse = true })
      hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
      hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
    end,
  },
}
