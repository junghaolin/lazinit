-- neovim/nvim/lua/config/options.lua
-- 基本設置 (Basic Settings)

-- 啟用系統剪貼板
vim.opt.clipboard:append("unnamedplus")

-- 縮排與 Tab 設定
vim.opt.expandtab = true   -- 將 Tab 鍵轉換為空格
vim.opt.shiftwidth = 2     -- 自動縮排時使用 2 個空格
vim.opt.tabstop = 2        -- Tab 鍵顯示為 2 個空格

-- 折疊設定 (Treesitter)
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Neovim 0.11+ 新 API
vim.o.foldlevel = 99       -- 默認展開所有折疊
vim.o.foldlevelstart = 99

-- 其他實用設定
vim.opt.number = true      -- 顯示行號
vim.opt.relativenumber = true -- 相對行號
vim.opt.ignorecase = true  -- 搜尋時忽略大小寫
vim.opt.smartcase = true   -- 若包含大寫字母則精確匹配
vim.opt.termguicolors = true -- 啟用全彩支援

-- Linter 與診斷顯示優化 (讓警告不要太干擾)
vim.diagnostic.config({
  -- 行末的虛擬文字 (Virtual Text)：設定為只顯示 ERROR，隱藏 WARNING (例如 MD022)
  virtual_text = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  signs = true,             -- 依然在左側保留圖示提示
  underline = true,         -- 依然保留底線提示
  update_in_insert = false, -- 在插入模式打字時，不要一直更新診斷
  severity_sort = true,     -- 錯誤優先顯示
})
