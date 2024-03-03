return {
   {
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      "neovim/nvim-lspconfig",
      ---@class PluginLspOpts
      opts = {
         ---@type lspconfig.options
         servers = {
            docker_compose_language_service = {},
            golangci_lint_ls = {
               init_options = {
                  command = {
                     "golangci-lint",
                     "run",
                     "--new",
                     "--config",
                     "~/.golangci.yaml",
                     "--out-format",
                     "json",
                  },
               },
            },
            sqlls = {},
         },
      },
   },
}
