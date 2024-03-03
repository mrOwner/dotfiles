local Util = require("lazyvim.util")

local function addPath(command, rep, list)
   local handle = io.popen(command)
   if handle ~= nil then
      local result = handle:read("*a"):gsub("\n$", "")
      handle:close()

      if result ~= nil and result ~= "" then
         list[result] = rep
      end
   end
end

-- Здесь добавлять начала путей которые следует заменить.
local replacements = {
   [vim.fn.getenv("HOME")] = "~",
   [vim.fn.getcwd()] = ".",
   [vim.fn.getenv("GOROOT")] = "$GOROOT",
}

-- Либо здесь добавлять команды путей для замены.
addPath("rustc --print sysroot 2>&1", "$RUST_SYSROOT", replacements)
addPath("go env GOMODCACHE 2>&1", "$GOMODCACHE", replacements)

return {
   "nvim-telescope/telescope.nvim",
   keys = {
      { "<leader>*", Util.telescope("grep_string", { cwd = false }), desc = "Word (cwd)" },
      { "<leader>'", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
   },
   opts = {
      defaults = {
         mappings = {
            i = {
               -- ["<Esc>"] = require("telescope.actions").close,
               ["<C-j>"] = require("telescope.actions").move_selection_next,
               ["<C-k>"] = require("telescope.actions").move_selection_previous,
            },
         },
         layout_config = {
            horizontal = {
               preview_width = 0.4,
               width = 0.8,
            },
            -- other layout configuration here
         },
         -- Здесь добавлять regex нежедательных файлов через запятую.
         -- https://www.lua.org/manual/5.1/manual.html#5.4.1
         file_ignore_patterns = {
            -- в паттернах lua нет отрицания.
            -- в нашем домене три точки.
            "vendor/[%l%d-_]+%.[%l%d-_]+/.+", -- одна точки в домене.
            "vendor/[%l%d-_]+%.[%l%d-_]+%.[%l%d-_]+/.+", -- две точки в домене.
            ".+%.pb%.go",
            ".+mock%.go",
            -- ".+_test%.go",
         },
         -- tail, smart, absolute, shorten, truncate
         -- path_display = { "smart" },
         -- path_display = {
         --     shorten = 6,
         -- },
         path_display = function(_, path)
            for prefix, replacement in pairs(replacements) do
               if string.sub(path, 1, string.len(prefix)) == prefix then
                  path = replacement .. string.sub(path, string.len(prefix) + 1)
                  break
               end
            end

            return path
         end,
      },
      pickers = {
         find_files = {
            --find_command = {'rg', '--files', '--no-ignore', '--follow', '--hidden', '--color', 'never'}
            hidden = true,
            no_ignore = true,
            follow = true,
         },
         -- jumplist = {
         --    fname_width = 1000,
         -- },
         lsp_references = {
            show_line = true,
            fname_width = 70,
            trim_text = true,
         },
         -- lsp_incoming_calls = {
         --    fname_width = 1000,
         -- },
         lsp_implementations = {
            fname_width = 70,
            trim_text = true,
         },
         lsp_document_symbols = {
            -- fname_width = 1000,
            symbol_width = 60,
            -- symbol_type_width = 1000,
         },
         lsp_workspace_symbols = {
            -- fname_width = 1000,
            symbol_width = 60,
            -- symbol_type_width = 10,
         },
         lsp_dynamic_workspace_symbols = {
            -- fname_width = 1000,
            symbol_width = 60,
            -- symbol_type_width = 10,
         },
      },
   },
}
