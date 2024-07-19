return {
   {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
         popup_border_style = "rounded",
         window = {
            mappings = {
               ["<space>"] = "none",
               ["l"] = "open",
               ["h"] = "close_node",
               ["s"] = "open_split",
               ["v"] = "open_vsplit",
            },
         },
         filesystem = {
            filtered_items = {
               visible = false, -- when true, they will just be displayed differently than normal items
               hide_dotfiles = true,
               hide_gitignored = true,
               hide_hidden = true, -- only works on Windows for hidden files/directories
               always_show = { -- remains visible even if other settings would normally hide it
                  ".gitignore",
                  ".env",
                  ".golangci.yml",
                  ".vscode",
                  "vendor",
               },
            },
         },
      },
   },
   {
      -- It's need for neotree to open windows.
      "s1n7ax/nvim-window-picker",
      config = function()
         require("window-picker").setup()
      end,
   },
}
