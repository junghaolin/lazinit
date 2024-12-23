return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			enabled = true, -- 默認關閉
		},
		config = function(_, opts)
			require("ibl").setup(opts)
		end,
		keys = {
			{
				"<leader>ui",
				function() -- 更新配置來啟用或禁用標示線
					local current_config = vim.g.ibl_enabled or false
					vim.g.ibl_enabled = not current_config
					require("ibl").setup({ enabled = vim.g.ibl_enabled })
					vim.opt.number = not current_config
					vim.opt.relativenumber = not current_config
				end,
				desc = "Toggle indent lines and line numbers",
			},
		},
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				-- Neo-tree 配置
			})
		end,
	},
	{ "nvim-tree/nvim-web-devicons" },
	{ "MunifTanjim/nui.nvim" },
}
