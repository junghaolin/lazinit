-- Neovim Configuration File
-- Bootstrapped for LazyVim

-- 設定 leader 鍵為空格 (Must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 載入基本設定 (Load basic options before lazy.nvim)
require("config.options")

-- =====================================================
-- Bootstrap lazy.nvim
-- =====================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- =====================================================
-- Setup lazy.nvim
-- =====================================================
require("lazy").setup({
  spec = {
    -- 引入 LazyVim 核心
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    
    -- 引入官方額外語言支援
    { import = "lazyvim.plugins.extras.lang.markdown" },
    
    -- 自動引入 lua/plugins 目錄下的所有自定義插件
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false, -- always use the latest git commit
  },
  checker = { enabled = true }, -- automatically check for plugin updates
})

-- 載入快捷鍵與自定義函數 (Load keymaps after lazy.nvim)
require("config.keymaps")
