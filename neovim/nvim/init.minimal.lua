-- Neovim 極簡化配置 (Minimal Mode)
-- 適用於：樹莓派、開發板、或資源受限環境

-- =====================================================
-- 1. 基本設定 (Basic Settings)
-- =====================================================
vim.g.mapleader = " "
vim.opt.clipboard:append("unnamedplus")
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- =====================================================
-- 2. 極簡插件管理 (Minimal Plugins)
-- =====================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- 1. 語法高亮 (核心)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs", -- 指定主模組，讓 lazy 自動執行 setup
    opts = {
      ensure_installed = { "c", "lua", "python", "bash", "markdown" },
      highlight = { enable = true },
    },
  },
  -- 2. 極速導航 (取代 Telescope，效能更高)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
      { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Search Grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<C-e>", "<cmd>FzfLua live_grep<cr>", desc = "Global Search" },
    },
    opts = {}
  },
  -- 3. 檔案目錄 (輕量化)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
    },
    opts = {
      filesystem = { filtered_items = { visible = true } }
    }
  },
  -- 4. 終端機 (必備)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { { "<leader>t", "<cmd>ToggleTerm direction=horizontal size=15<cr>", desc = "Terminal" } },
    opts = { open_mapping = [[<leader>t]], direction = "horizontal", size = 15 }
  }
})

-- =====================================================
-- 3. 快捷鍵 (Keymaps)
-- =====================================================
local map = vim.keymap.set
map("n", "<Tab>", ":bnext<CR>", { silent = true })
map("n", "<S-Tab>", ":bprev<CR>", { silent = true })
map("n", "<esc>", ":noh<cr>", { silent = true })
map("t", "<C-t>", "<C-\\><C-n>", { silent = true })
