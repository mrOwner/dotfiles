-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local utils = require("utils.splits")
local os_name = vim.loop.os_uname().sysname

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

-- New line.
map("n", "<C-j>", "o<Esc>", { silent = true })
if os_name == "Darwin" then
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
map({ "n", "x" }, "gl", "$", { silent = true })

-- Delete.
map("i", "<C-l>", "<Del>", { silent = true })

-- File.
map("n", "<leader>fs", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "<leader>fcr", ':let @+ = expand("%")<cr>', { desc = "Copy relative path" })
map("n", "<leader>fca", ':let @+ = expand("%:p")<cr>', { desc = "Copy absolute path" })
map("n", "<leader>fcf", ':let @+ = expand("%:t")<cr>', { desc = "Copy filename" })

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
map("n", "<leader>we", ":Neotree focus<cr>", { desc = "NeoTree focus" })

-- Move Lines.
if os_name == "Darwin" then
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
map("n", "z1", "<cmd>%s/^func [a-zA-Z0-9_]*(/norm zc<cr><esc>", { desc = "Fold 1 level" })

-- Search and replace
map("n", "<leader>R", ":%s/\\v(<C-r><C-w>)/\\1/g<left><left>", { desc = "Search and replace" })

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
