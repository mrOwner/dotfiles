-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.colorcolumn = "120"

vim.g.ai_cmp = false
vim.g.lazyvim_blink_main = true

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

-- for vacuum
vim.filetype.add({
  pattern = {
    [".*openapi.*%.ya?ml"] = "yaml.openapi",
    [".*swagger.*%.ya?ml"] = "yaml.openapi",
    [".*openapi.*%.json"] = "json.openapi",
  },
})
