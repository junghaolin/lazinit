-- Neovim 極簡化配置 (Minimal Mode - 2026 穩定版)
-- 適用於：樹莓派、開發板、或資源受限環境

-- =====================================================
-- 1. 基本設定
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
-- 2. 極簡插件管理 (使用 Lazy.nvim)
-- =====================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- 1. 語法高亮 (最新 v1.0 適配版)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- 使用 opts 而非 config 函數，這是目前最穩定的做法
    opts = {
      ensure_installed = { "c", "lua", "python", "bash", "markdown" },
      highlight = { enable = true },
    },
    config = function(_, opts)
      -- 增加 pcall 以應對外掛架構變動
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        configs.setup(opts)
      else
        -- 如果是新版 v1.0+，直接呼叫內建 setup
        require("nvim-treesitter").setup(opts)
      end
    end,
  },
  -- 2. 極速導航 (fzf-lua)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
      { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Search Grep" },
      { "<C-e>", "<cmd>FzfLua live_grep<cr>", desc = "Global Search" },
    },
    opts = {}
  },
  -- 3. 檔案目錄
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
  -- 4. 終端機
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { { "<leader>t", "<cmd>ToggleTerm direction=horizontal size=15<cr>", desc = "Terminal" } },
    opts = { open_mapping = [[<leader>t]], direction = "horizontal", size = 15 }
  }
})

-- =====================================================
-- 3. 快捷鍵
-- =====================================================
local map = vim.keymap.set
map("n", "<Tab>", ":bnext<CR>", { silent = true })
map("n", "<S-Tab>", ":bprev<CR>", { silent = true })
map("n", "<esc>", ":noh<cr>", { silent = true })
map("t", "<C-t>", "<C-\\><C-n>", { silent = true })
