-- neovim/nvim/lua/config/keymaps.lua
-- 快捷鍵映射與自定義函數 (Key Mappings & Functions)

local map = vim.keymap.set
local api = vim.api

-- 切換緩衝區 (Switch buffers)
map("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer", silent = true })
map("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer", silent = true })

-- Neotree
map("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Explorer", noremap = true, silent = true })
map("n", "<leader>nf", ":Neotree filesystem<CR>", { desc = "Neotree Filesystem", noremap = true, silent = true })
map("n", "<leader>ng", ":Neotree git_status<CR>", { desc = "Neotree Git", noremap = true, silent = true })

-- 終端機 (Terminal) 管理已移交給 toggleterm.nvim 處理
-- 快捷鍵為 <leader>t (開啟/關閉) 與 <C-t> (退出終端模式)

-- 代碼格式化 (Format code)
map("n", "<C-s>", function() vim.lsp.buf.format() end, { desc = "Format Code", noremap = true, silent = true })

-- Telescope 全局搜索 (Global search)
map("n", "<C-e>", ":Telescope live_grep<CR>", { desc = "Global search", noremap = true, silent = true })

-- 取消搜尋高亮
map("n", "<esc>", ":noh<cr>", { desc = "Clear search highlights", silent = true })
