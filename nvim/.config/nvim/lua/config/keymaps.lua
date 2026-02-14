-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local utils = require("util.util")
local its_mac = vim.fn.has("macunix")

-- Cmd line.
map("c", "<C-j>", "<C-n>")
map("c", "<C-k>", "<C-p>")

-- remaps.
-- i don"t want to copy everything to my clipboard."
map("n", "c", '"_c', { silent = true })
map("x", "p", '"_c<esc>p', { silent = true })
-- i often make mistake.
map("v", "<C-o>", "<Esc><C-o>", { silent = true })
map("v", "<C-i>", "<Esc><C-i>", { silent = true })

-- returned back standart behavior
map({ "n", "x" }, "j", "'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "'k'", { desc = "Up", expr = true, silent = true })

-- New line.
map("n", "<C-j>", "o<Esc>", { silent = true })
if its_mac == 1 then
  map("n", "<D-j>", "i<Cr><Esc>", { silent = true, desc = "Tear down" })
  map("n", "<D-k>", "i<Cr><Esc>k", { silent = true, desc = "Tear up and come back" })
else
  map("n", "<A-j>", "i<Cr><Esc>", { silent = true, desc = "Tear down" })
  map("n", "<A-k>", "i<Cr><Esc>k", { silent = true, desc = "Tear down and come back" })
end

-- Moving.
map("i", "<C-e>", "<C-o>$", { silent = true })
map("i", "<C-a>", "<C-o>^", { silent = true })
map({ "n", "x" }, "gh", "^", { silent = true })
map({ "n", "x" }, "gl", "g_", { silent = true })

-- Delete.
map("i", "<C-l>", "<Del>", { silent = true })

-- File.
map("n", "<leader>fs", "<cmd>w<cr><esc>", { desc = "Save file" })

map("n", "<leader>fcr", function()
  local path = vim.fn.expand("%")
  vim.fn.setreg("+", path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, { desc = "Copy relative path" })

map("n", "<leader>fca", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, { desc = "Copy absolute path" })

map("n", "<leader>fcf", ':let @+ = expand("%:t")<cr>', { desc = "Copy filename" })

map("n", "<leader>fcl", function()
  local path = vim.fn.expand("%")
  local line = vim.fn.line(".")
  local full = path .. ":" .. line
  vim.fn.setreg("+", full)
  vim.notify('Copied "' .. full .. '" to the clipboard!')
end, { desc = "Copy path and line" })

map("n", "<leader>fcg", function()
  require("copypath").copy_path_with_line()
end, { desc = "Copy path to gitlab" })

map("n", "<leader>fcv", function()
  local path = vim.fn.expand("%")
  local line = vim.fn.line(".")
  local full = path .. ":" .. line
  vim.system({ "code", "-g", full })
end, { desc = "Open in vscode" })

map("n", "<leader>fcz", function()
  local path = vim.fn.expand("%")
  local line = vim.fn.line(".")
  local full = path .. ":" .. line
  vim.system({ "zed", full })
end, { desc = "Open in zed" })

-- Buffers.
map("n", "<leader>bh", "<cmd>Bdelete hidden<cr>", { desc = "Close hidden" })
map("n", "<leader>bu", "<cmd>e!<cr>", { desc = "Reread current buffer" })

-- Windows.
map("n", "<leader>ws", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>wv", "<C-W>v", { desc = "Split window right" })
map("n", "<leader>w=", "<C-W>=", { desc = "Balance" })
map("n", "<leader>wm", "<C-W>T", { desc = "Maximize" })
map("n", "<leader>wx", "<C-W>x", { desc = "Swap" })
map("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })
-- map("n", "<leader>e", utils.Focus, { desc = "NeoTree focus" })

-- Move Lines.
if its_mac == 1 then
  map("n", "<D-Down>", "<cmd>m .+1<cr>==", { desc = "Move down" })
  map("n", "<D-Up>", "<cmd>m .-2<cr>==", { desc = "Move up" })
  map("i", "<D-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
  map("i", "<D-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
  map("v", "<D-Down>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
  map("v", "<D-Up>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
else
  map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move down" })
  map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move up" })
  map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
  map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
  map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
  map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move up" })
end

-- LSP
map("n", "<leader>ct", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "Type definition" })

-- Folds.
-- map("n", "z1", "<cmd>%s/^func [a-zA-Z0-9_]*(/norm zc<cr><esc>", { desc = "Fold 1 level" })
map("n", "z1", ":set foldlevel=0<cr>", { desc = "Fold 0 level" })
map("n", "z2", ":set foldlevel=1<cr>", { desc = "Fold 1 level" })
map("n", "z3", ":set foldlevel=2<cr>", { desc = "Fold 2 level" })
map("n", "z4", ":set foldlevel=3<cr>", { desc = "Fold 3 level" })
map("n", "z5", ":set foldlevel=4<cr>", { desc = "Fold 4 level" })
map("n", "z6", ":set foldlevel=5<cr>", { desc = "Fold 5 level" })
map("n", "z7", ":set foldlevel=6<cr>", { desc = "Fold 6 level" })
map("n", "z8", ":set foldlevel=7<cr>", { desc = "Fold 7 level" })
map("n", "z9", ":set foldlevel=8<cr>", { desc = "Fold 8 level" })

-- Search and replace
map("n", "<leader>mr", ":%s/\\v(<C-r><C-w>)/\\1/g<left><left>", { desc = "Search and replace" })
map("v", "<leader>mr", ":s/\\v(<C-r><C-w>)/\\1/g<left><left>", { desc = "Search and replace" })

-- My splits.
map("n", "<leader>msf", function()
  utils.FormatGoFunction()
end, { desc = "Split go function" })
map("n", "<leader>msd", function()
  utils.FormatByDot()
end, { desc = "Split by dot" })
map("n", "<leader>msc", function()
  utils.FormatByComma()
end, { desc = "Split by comma" })

-- Usability
-- map("n", "<leader>mt", ":!go mod tidy&<cr>", { desc = "Go mod tidy" })
map("n", "<leader>md", function()
  vim.fn.jobstart({ "go", "mod", "tidy" }, {
    on_exit = function(_, code, _)
      local msg = code == 0 and "✅ go mod tidy completed" or ("❌ go mod tidy failed with code " .. code)
      vim.schedule(function()
        vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
      end)
    end,
  })
end, { desc = "Go mod tidy" })

map("n", "<leader>mg", function()
  vim.fn.jobstart({ "go", "generate", "./..." }, {
    on_exit = function(_, code, _)
      local msg = code == 0 and "✅ go generate completed" or ("❌ go generate failed with code " .. code)
      vim.schedule(function()
        vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
      end)
    end,
  })
end, { desc = "Go generate" })

map("n", "<leader>go", function()
  utils.OpenGitlabMR()
end, { desc = "Open gitlab mr" })

map("n", "go", utils.gs_lsp_def_in_right, { silent = true })
