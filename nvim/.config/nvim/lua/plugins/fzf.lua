return {
   "ibhagwan/fzf-lua",
   keys = {
      { "<leader>'", "<cmd>FzfLua resume<cr>", desc = "Resume last search" },
      { "<leader>*", LazyVim.pick("grep_cword", { root = false }), desc = "Word (cwd)" },
      { "<leader>*", LazyVim.pick("grep_visual", { root = false }), mode = "v", desc = "Selection (cwd)" },
      { "<leader>fR", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
      { "<leader>fr", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },
   },
}
