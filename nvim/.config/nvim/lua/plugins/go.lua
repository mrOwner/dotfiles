return {
  -- which key integration
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n" },
          { "<leader>tc", group = "Coverage" },
          { "<leader>to", group = "Open test" },
        },
      },
    },
  },
  {
    "fang2hou/go-impl.nvim",
    ft = "go",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",

      -- Choose one of the following fuzzy finder
      "folke/snacks.nvim",
      -- "ibhagwan/fzf-lua",
    },
    keys = {
      {
        "<leader>mi",
        function()
          require("go-impl").open()
        end,
        mode = { "n" },
        desc = "Go Impl",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      local lint = require("lint")

      local golangcilint = lint.linters.golangcilint
      table.insert(golangcilint.args, "--new")
      table.insert(golangcilint.args, "--config=" .. vim.fn.expand("~/.golangci.yaml"))

      -- betteralign: struct field alignment hints (github.com/dkorunic/betteralign)
      -- install: go install github.com/dkorunic/betteralign/cmd/betteralign@latest
      lint.linters.betteralign = {
        name = "betteralign",
        cmd = "betteralign",
        stdin = false,
        append_fname = false,
        -- analyze the package (directory) of the current file
        args = {
          function()
            return vim.fn.expand("%:p:h")
          end,
        },
        stream = "stderr",
        ignore_exitcode = true, -- exits non-zero when suggestions are found
        parser = function(output, bufnr)
          local diagnostics = {}
          local fname = vim.api.nvim_buf_get_name(bufnr)
          for line in vim.gsplit(output, "\n", { trimempty = true }) do
            local file, lnum, col, msg = line:match("^(.-):(%d+):(%d+): (.+)$")
            -- betteralign reports the whole package; keep only the current buffer
            if file and vim.fn.fnamemodify(file, ":p") == fname then
              table.insert(diagnostics, {
                lnum = tonumber(lnum) - 1,
                col = tonumber(col) - 1,
                end_lnum = tonumber(lnum) - 1,
                end_col = tonumber(col) - 1,
                severity = vim.diagnostic.severity.HINT,
                source = "betteralign",
                message = msg,
              })
            end
          end
          return diagnostics
        end,
      }

      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.go = opts.linters_by_ft.go or {}
      table.insert(opts.linters_by_ft.go, "betteralign")
      return opts
    end,
  },
}
