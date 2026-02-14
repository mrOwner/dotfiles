-- https://go.googlesource.com/tools/+/refs/heads/master/gopls/doc/inlayHints.md
-- https://github.com/neovim/nvim-lspconfig/blob/7af2c37192deae28d1305ae9e68544f7fb5408e1/doc/configs.md
-- https://www.andersevenrud.net/neovim.github.io/lsp/configurations/gopls/
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "gopls",
        "golangci_lint_ls",
        "vacuum",
        "lua_ls",
      },
    },
    config = function()
      local utils = require("util.util")

      utils.Install("bufls", "go install github.com/bufbuild/buf-language-server/cmd/bufls@latest")
      utils.Install("kulala-ls", "npm install -g @mistweaverco/kulala-ls")
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "kulala-fmt",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        bufls = {},
        -- copilot = {
        --   keys = {
        --     {
        --       "<S-Tab>",
        --       function()
        --         if vim.lsp.inline_completion then
        --           vim.lsp.inline_completion.get()
        --         end
        --       end,
        --       mode = "i",
        --       desc = "Accept Copilot Suggestion",
        --     },
        --   },
        -- },
        gopls = {
          settings = {
            gopls = {
              ["local"] = "set-alias",
              gofumpt = true,
              codelenses = {
                gc_details = true,
              },
              hints = {
                assignVariableTypes = false,
                functionTypeParameters = false,
                parameterNames = false,
                compositeLiteralTypes = false,
              },
              matcher = "Fuzzy",
              analyses = {
                analyses = {
                  shadow = true,
                },
              },
            },
          },
          on_attach = function(client)
            if client.server_capabilities.codeLensProvider then
              vim.lsp.codelens.refresh()
            end
          end,
        },
        golangci_lint_ls = { enabled = false },
        kulala_ls = {
          capabilities = vim.lsp.protocol.make_client_capabilities(),
        },
        lua_ls = {},
        vacuum = {},
      },
    },
  },
}
