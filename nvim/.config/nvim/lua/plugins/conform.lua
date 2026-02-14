return {
  -- formatter
  -- https://github.com/stevearc/conform.nvim
  -- https://neovimcraft.com/plugin/stevearc/conform.nvim/
  "stevearc/conform.nvim",
  -- optional = true,
  opts = function(_, opts)
    opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
      go = { "gci" },
      yaml = { "prettier" },
    })

    opts.formatters = vim.tbl_extend("force", opts.formatters or {}, {
      gci = {
        command = "gci",
        args = {
          "write",
          "--skip-vendor",
          "--skip-generated",
          "--custom-order",
          "-s",
          "standard",
          "-s",
          "default",
          "-s",
          "localmodule",
          "$FILENAME",
        },
        stdin = false,
      },
      sqlfluff = {
        args = { "fix", "$FILENAME" },
        stdin = false,
      },
      prettier = {
        prepend_args = function(self, ctx)
          if vim.bo[ctx.buf].filetype == "yaml" then
            return { "--single-quote" }
          end
          return {}
        end,
      },
    })

    -- Further below the overword of Lazyvim Format to format only changed lines

    local format = require("conform").format
    local gitsigns = require("gitsigns")

    local function format_hunks(bufnr)
      local hunks = gitsigns.get_hunks(bufnr)
      if not hunks then
        return
      end

      local function format_range()
        if next(hunks) == nil then
          vim.notify("done formatting git hunks", "info", { title = "formatting" })
          return
        end
        local hunk = nil
        while next(hunks) ~= nil and (hunk == nil or hunk.type == "delete") do
          hunk = table.remove(hunks)
        end

        if hunk ~= nil and hunk.type ~= "delete" then
          local start = hunk.added.start
          local last = start + hunk.added.count
          -- nvim_buf_get_lines uses zero-based indexing -> subtract from last
          local last_hunk_line = vim.api.nvim_buf_get_lines(0, last - 2, last - 1, true)[1]
          local range = { start = { start, 0 }, ["end"] = { last - 1, last_hunk_line:len() } }
          -- vim.notify(
          --   string.format("Formatting range: [%d,0] to [%d,%d]", start, last - 1, #last_hunk_line),
          --   vim.log.levels.INFO,
          --   { title = "FormatHunks" }
          -- )
          format({ range = range, async = true, lsp_fallback = true }, function()
            vim.defer_fn(function()
              format_range()
            end, 1)
          end)
        end
      end

      format_range()
    end

    -- Command to manual call
    vim.api.nvim_create_user_command("FormatHunks", function()
      format_hunks(vim.api.nvim_get_current_buf())
    end, { desc = "Format Git hunks" })

    vim.api.nvim_create_user_command("Format", function(cmd_opts)
      local conform = require("conform")
      local range = nil
      if cmd_opts.range == 2 then
        range = {
          start = { cmd_opts.line1, 0 },
          ["end"] = { cmd_opts.line2 + 1, 0 },
        }
      end

      conform.format({
        range = range,
        async = true,
        lsp_fallback = true,
      })
    end, {
      desc = "Format buffer or visual range with conform.nvim",
      range = true,
    })

    -- Toggle global
    vim.api.nvim_create_user_command("FormatHunksToggle", function()
      vim.g.format_modifications_only = not vim.g.format_modifications_only
      vim.notify(
        "Format hunks only: " .. tostring(vim.g.format_modifications_only),
        vim.log.levels.INFO,
        { title = "Conform" }
      )
    end, {})

    -- Reduce LazyVim.format.format
    local lazy_format = require("lazyvim.util").format
    local original_format = lazy_format.format

    lazy_format.format = function(cmd_opts)
      local buf = cmd_opts.buf or vim.api.nvim_get_current_buf()
      if not ((cmd_opts and cmd_opts.force) or lazy_format.enabled(buf)) then
        return
      end

      if vim.g.format_modifications_only then
        format_hunks(buf)
      else
        original_format(cmd_opts)
      end
    end

    vim.keymap.set("n", "<leader>ux", "<cmd>FormatHunksToggle<cr>", { desc = "Toggle format Git hunks only" })

    return opts
  end,
}
