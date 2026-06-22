require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "git open lazygit" })

-- option + arrow word jump
map("n", "<M-Left>",  "b",      { desc = "Jump word left" })
map("n", "<M-Right>", "w",      { desc = "Jump word right" })
map("i", "<M-Left>",  "<C-o>b", { desc = "Jump word left" })
map("i", "<M-Right>", "<C-o>w", { desc = "Jump word right" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
