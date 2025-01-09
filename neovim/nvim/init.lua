-- Neovim 配置文件
-- Neovim Configuration File

-- =====================================================
-- 1. 基本設置 (Basic Settings)
-- =====================================================

-- 設定 leader 鍵為空格
-- Set leader key to space
vim.g.mapleader = " "

-- 啟用系統剪貼板
-- Enable system clipboard
vim.opt.clipboard:append("unnamedplus")

-- 設定 Tab 為 2 個空格
-- Set Tab to 2 spaces
vim.opt.expandtab = true -- 將 Tab 鍵轉換為空格 (Convert Tab to spaces)
vim.opt.shiftwidth = 2 -- 自動縮排時使用 2 個空格 (Use 2 spaces for auto-indent)
vim.opt.tabstop = 2 -- Tab 鍵顯示為 2 個空格 (Display Tab as 2 spaces)

-- 設置 Neovim 使用 Treesitter 的折疊表達式
-- Set Neovim to use Treesitter folding expression
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevel = 1

-- =====================================================
-- 2. 插件管理 (Plugin Management)
-- =====================================================

-- 自動安裝
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- 設置 lazy.nvim 路徑
-- Set lazy.nvim path
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- 如果 lazy.nvim 不存在，則克隆它
-- Clone lazy.nvim if it doesn't exist
if vim.fn.filereadable(lazypath) == 1 then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

-- 將 lazy.nvim 添加到 runtimepath
-- Add lazy.nvim to runtimepath
vim.opt.rtp:prepend(lazypath)

-- 設置 lazy.nvim
-- Set up lazy.nvim
require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		{ import = "lazyvim.plugins.extras.lang.markdown" },
		{ import = "plugins.ui" }, -- 確保導入 ui.lua
		{ import = "plugins.comment" }, -- 確保導入 comment.lua
		{ import = "plugins.lsp" }, -- 確保導入 lsp.lua
		{ import = "plugins.completion" }, -- 確保導入 completion.lua
		{ import = "plugins.editor" }, -- 確保導入 editor.lua
		{ import = "plugins.utils" }, -- 確保導入 utils.lua
	},
})

--[[
local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lua" },
		{ name = "buffer" },
		{ name = "path" },
		{ name = "copilot" },
	}),
})
require("cmp").setup({
	sources = cmp.config.sources({
		{ name = "nvim_lua" },
		{ name = "buffer" },
		{ name = "path" },
	}),
})
]]
-- =====================================================
-- 3. 快捷鍵映射 (Key Mappings)
-- =====================================================

-- 切換緩衝區
-- Switch buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer" })

-- 打開/關閉 Neotree
-- Toggle Neotree
vim.api.nvim_set_keymap("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true })

-- 打開文件系統模式
-- Open filesystem mode
vim.api.nvim_set_keymap("n", "<leader>nf", ":Neotree filesystem<CR>", { noremap = true, silent = true })

-- 打開 Git 狀態模式
-- Open Git status mode
vim.api.nvim_set_keymap("n", "<leader>ng", ":Neotree git_status<CR>", { noremap = true, silent = true })

-- 打開終端
-- Open terminal
vim.api.nvim_set_keymap("n", "<leader>t", ":lua OpenTerminalOneThird()<CR>", { noremap = true, silent = true })

-- 從終端模式切換到普通模式
-- Switch from terminal mode to normal mode
vim.api.nvim_set_keymap("t", "<C-t>", "<C-\\><C-n>", { noremap = true, silent = true })

-- 格式化代碼
-- Format code
vim.api.nvim_set_keymap("n", "<C-s>", ":lua vim.lsp.buf.format()<CR>", { noremap = true, silent = true })

-- Telescope 全局搜索
-- Telescope global search
vim.keymap.set("n", "<C-e>", ":Telescope live_grep<CR>", { desc = "Global search", noremap = true, silent = true })

-- =====================================================
-- 4. 自定義函數 (Custom Functions)
-- =====================================================

-- 打開佔據三分之一屏幕高度的終端
-- Open a terminal occupying one-third of the screen height
function OpenTerminalOneThird()
	local height = math.floor(vim.o.lines / 3)
	vim.cmd("belowright split | resize " .. height .. " | terminal")
	vim.cmd("startinsert") -- 進入插入模式 (Enter insert mode)
end

-- =====================================================
-- 5. 自動命令 (Autocommands)
-- =====================================================

-- 啟動時自動打開 Neotree
-- Automatically open Neotree on startup
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("Neotree show focus")
			vim.defer_fn(function()
				vim.api.nvim_win_set_option(0, "number", false)
				vim.api.nvim_win_set_option(0, "relativenumber", false)
			end, 50)
		end
	end,
})
--[[
vim.api.nvim_create_autocmd("BufReadPre", {
	pattern = "*",
	callback = function()
		if vim.fn.getfsize(vim.fn.expand("%")) > 1024 * 1024 then
			vim.o.binary = true
			--vim.o.editable = false
			vim.cmd("%!xxd")
			vim.bo.filetype = "xxd"
		end
	end,
})
]]
