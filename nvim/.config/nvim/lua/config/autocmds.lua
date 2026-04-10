-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Автоформатирование файлов при сохранении
-- https://github.com/golang/tools/blob/master/gopls/doc/editor/vim.md
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end,
})

-- Переходит сразу по пути
-- Пример:
-- :P path/to/file.go:123
vim.api.nvim_create_user_command("P", function(opts)
  -- поддерживаем варианты: file:line или file:line:col
  local path, line, col = string.match(opts.args, "^(.-):(%d+):(%d+)$")
  if not path then
    path, line = string.match(opts.args, "^(.-):(%d+)$")
  end

  if path and line then
    vim.cmd("edit " .. path)
    local lnum = tonumber(line)
    local cnum = tonumber(col) or 1
    vim.api.nvim_win_set_cursor(0, { lnum, cnum - 1 })
  else
    vim.notify("Invalid input. Use: path/to/file.go:123 or path/to/file.go:123:32", vim.log.levels.ERROR)
  end
end, { nargs = 1, complete = "file" })

-- Replace spaces in t.Run test names with underscores
vim.api.nvim_create_user_command("FixTestNames", function()
  vim.cmd([[
      %s/\(name:\s*"\)\([^"]*\)\("\)/\=submatch(1) . substitute(submatch(2), ' ', '_', 'g') . submatch(3)/e
    ]])

  vim.cmd([[
      %s/\(\.Run("\)\([^"]*\)\(", func(\)/\=submatch(1) . substitute(submatch(2), ' ', '_', 'g') . submatch(3)/e
    ]])
end, { desc = "Replace spaces in t.Run test names with underscores" })

vim.api.nvim_create_user_command("Sum", function(opts)
  -- Получаем выделенный текст
  local _, s_line, s_col, _ = unpack(vim.fn.getpos("'<"))
  local _, e_line, e_col, _ = unpack(vim.fn.getpos("'>"))
  local lines = vim.api.nvim_buf_get_lines(0, s_line - 1, e_line, false)
  if #lines == 1 then
    lines[1] = lines[1]:sub(s_col, e_col)
  else
    lines[1] = lines[1]:sub(s_col)
    lines[#lines] = lines[#lines]:sub(1, e_col)
  end
  local str = table.concat(lines, " ")
  local sum = 0
  -- Ищем все числа (включая отрицательные и дробные)
  for n in str:gmatch("-?%d+%.?%d*") do
    sum = sum + tonumber(n)
  end
  print("Сумма: " .. sum)
end, { range = true, desc = "Sum numbers in selection" })
