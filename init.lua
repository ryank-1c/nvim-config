-- ============================================================
-- environment
-- ============================================================
vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH

-- ============================================================
-- lazy.nvim bootstrap
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- plugins
-- ============================================================
require("lazy").setup({
  "nvim-mini/mini.nvim",
  "tpope/vim-fugitive",
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },
  "neovim/nvim-lspconfig",
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "kdheepak/lazygit.nvim",
  "navarasu/onedark.nvim",
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          use_libuv_file_watcher = true,
          follow_current_file = {
            enabled = true,
          },
          filtered_items = {
            hide_gitignored = false,
            hide_dotfiles = false,
          },
        },
        window = {
          mappings = {
            ["R"] = "refresh",
          },
        },
      })

      -- Refresh when returning focus (catches git branch switches)
      vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
        callback = function()
          local manager = require("neo-tree.sources.manager")
          local state = manager.get_state("filesystem")
          -- Only refresh if the tree has already been rendered
          if state and state.tree then
            manager.refresh("filesystem")
          end
        end,
      })
    end
  },
})

-- ============================================================
-- mini modules
-- ============================================================
require('mini.pick').setup()
require('mini.comment').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.statusline').setup()
require('mini.completion').setup()
require('mini.diff').setup()
require('mini.git').setup()
require('mini.icons').setup()
require('mini.ai').setup()

-- ============================================================
-- colorscheme
-- ============================================================
require('onedark').setup({ style = 'dark', transparent = true })
require('onedark').load()

-- ============================================================
-- mason (language server installer)
-- ============================================================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "dockerls", "ts_ls", "terraformls" },
  automatic_installation = true,
})

-- ============================================================
-- LSP
-- ============================================================

-- Pyright: type checking + completions, matching VS Code's Pylance defaults
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        typeCheckingMode        = "basic",
        autoImportCompletions   = true,
        autoSearchPaths         = true,
        useLibraryCodeForTypes  = true,
        diagnosticMode          = "workspace",
        inlayHints = {
          variableTypes      = true,
          functionReturnTypes = true,
          callArgumentNames  = "all",
          pytestParameters   = true,
        },
      },
    },
  },
})
vim.lsp.enable('pyright')

-- Ruff: linting + formatting (matches VS Code Python extension defaults)
vim.lsp.config('ruff', {})
vim.lsp.enable('ruff')

vim.lsp.config('dockerls', {})
vim.lsp.enable('dockerls')

vim.lsp.config('ts_ls', {})
vim.lsp.enable('ts_ls')

vim.lsp.config('terraformls', {})
vim.lsp.enable('terraformls')

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = vim.keymap.set
    local opts = { buffer = args.buf }
    map("n", "gd",         vim.lsp.buf.definition,     opts)
    map("n", "K",          vim.lsp.buf.hover,           opts)
    map("n", "<leader>rn", vim.lsp.buf.rename,          opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action,     opts)
    map("n", "gr",         vim.lsp.buf.references,      opts)
    map("n", "[d",         vim.diagnostic.goto_prev,    opts)
    map("n", "]d",         vim.diagnostic.goto_next,    opts)
    -- inlay hints (parameter names, return types)
    vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
  end,
})

-- Enable treesitter highlighting for any filetype that has a parser installed
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Python: format on save with Ruff, 4-space indent (matches VS Code defaults)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({ name = "ruff", async = false })
  end,
})

-- dockerfile filetype detection
vim.filetype.add({
  filename = {
    ['Dockerfile'] = 'dockerfile',
  },
  pattern = {
    ['.*Dockerfile.*'] = 'dockerfile',
  }
})

-- ============================================================
-- general vim options
-- ============================================================
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.wrap           = false
vim.opt.termguicolors  = true
vim.opt.scrolloff      = 8
vim.opt.signcolumn     = "yes"
vim.opt.clipboard      = "unnamedplus"
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.mouse          = "a"
vim.opt.mousescroll    = "ver:3,hor:6"

-- ============================================================
-- keymaps
-- ============================================================
vim.g.mapleader = " "

local map = vim.keymap.set

-- file explorer (neo-tree takes over Space+e, mini.files on Space+E)
map("n", "<leader>e", function()
  local in_real_file = vim.bo.buftype == "" and vim.fn.expand("%") ~= ""
  vim.cmd(in_real_file and "Neotree reveal" or "Neotree toggle")
end, { desc = "Toggle file explorer" })

-- fuzzy finder
map("n", "<leader>ff", "<cmd>Pick files<cr>",             { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Pick grep_live<cr>",         { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Pick buffers<cr>",           { desc = "Find buffers" })

-- run current file
map("n", "<leader>r",  "<cmd>!python3 %<cr>",             { desc = "Run current file" })

-- window navigation
map("n", "<C-h>",      "<C-w>h",                          { desc = "Move to left window" })
map("n", "<C-l>",      "<C-w>l",                          { desc = "Move to right window" })
map("n", "<C-j>",      "<C-w>j",                          { desc = "Move to lower window" })
map("n", "<C-k>",      "<C-w>k",                          { desc = "Move to upper window" })

-- misc
map("n", "<leader>h",  "<cmd>nohlsearch<cr>",             { desc = "Clear highlights" })
map("n", "<leader>w",  "<cmd>w<cr>",                      { desc = "Save" })
map("n", "<leader>q",  "<cmd>q<cr>",                      { desc = "Quit" })

-- option + arrow word jump
map("n", "<M-Left>",   "b",                               { desc = "Jump word left" })
map("n", "<M-Right>",  "w",                               { desc = "Jump word right" })
map("i", "<M-Left>",   "<C-o>b",                          { desc = "Jump word left" })
map("i", "<M-Right>",  "<C-o>w",                          { desc = "Jump word right" })

-- lazygit
map("n", "<leader>g",  "<cmd>LazyGit<cr>",                { desc = "Open LazyGit" })

-- terminal
map("n", "<leader>t",  "<cmd>split | terminal<cr>",       { desc = "Open terminal split" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
