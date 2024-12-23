return {
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				padding = true,
				sticky = true,
				toggler = {
					line = "gcc",
					block = "gbc",
				},
				opleader = {
					line = "gc",
					block = "gb",
				},
				mappings = {
					basic = true,
					extra = false,
					extra_mappings = {
						["<leader>ca"] = { "gcc", "gc" },
					},
				},
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})

			-- 绑定快捷键
			vim.keymap.set("n", "<leader>cc", function()
				require("Comment.api").toggle.linewise.current()
			end, { desc = "Toggle comment for current line" })

			vim.keymap.set("v", "<leader>cc", function()
				require("Comment.api").toggle.linewise(vim.fn.visualmode())
			end, { desc = "Toggle comment for selected lines" })

			-- 操作符模式下的块注释
			vim.api.nvim_set_keymap("o", "gb", "<ESC>:'<,'>CommentToggle<CR>", { noremap = true, silent = true })
		end,
	},
	-- 可选依赖，用于动态注释符号支持
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		event = "BufRead",
	},
}
