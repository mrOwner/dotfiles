vim.filetype.add({
  pattern = {
    [".*/.vscode/.*%.json"] = "jsonc",
    [".*/.vscode/.*%.code%-snippets"] = "jsonc",
  },
})
