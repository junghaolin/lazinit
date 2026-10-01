return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			enabled = false, -- 默認關閉
		},
		config = function(_, opts)
			require("ibl").setup(opts)
		end,
		keys = {
			{
				"<leader>ui",
				function()
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
	{ "nvim-lua/plenary.nvim" },
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				close_if_last_window = true, -- 最後一個窗口時自動關閉
				popup_border_style = "rounded",
				enable_git_status = true,
				enable_diagnostics = true,
				window = {
					position = "left",
					width = 30,
					mapping_options = {
						noremap = true,
						nowait = true,
					},
				},
				filesystem = {
					filtered_items = {
						visible = false, -- 隱藏 dotfiles
						hide_dotfiles = true,
						hide_gitignored = true,
					},
					follow_current_file = {
						enabled = true, -- 自動跟隨當前文件
					},
					use_libuv_file_watcher = true, -- 自動刷新
				},
			})
		end,
	},
	{ "nvim-tree/nvim-web-devicons" },
	{ "MunifTanjim/nui.nvim" },
	--[[{
		"nvim-neorocks/rocks.nvim",
		opts = {
			rocks = { enabled = false },
		},
	},]]
	--[[{
		"vhyrro/luarocks.nvim",
		priority = 1001,
		opts = {
			rocks = { "magick" },
		},
	},]]
	--[[
	{
		"edluffy/hologram.nvim",
		enabled = false, -- 禁用以避免與 image.nvim 衝突
		config = function()
			require("hologram").setup({
				auto_display = true,
			})
		end,
	},
	]]
	{
		"3rd/image.nvim",
		event = "VeryLazy", -- 延迟加载避免启动错误
		enabled = function()
			return os.getenv("TERM_PROGRAM") ~= nil -- 只在终端环境中启用
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			backend = "kitty", -- 或 "ueberzug"
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki" },
				},
				neorg = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "norg" },
				},
			},
			max_width = nil,
			max_height = nil,
			max_width_window_percentage = 100,
			max_height_window_percentage = 100,
			window_overlap_clear_enabled = false,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			editor_only_render_when_focused = false,
			tmux_show_only_in_active_window = false,
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
			render_position = function(image_width, image_height, editor_width, editor_height)
				return {
					row = math.floor((editor_height - image_height) / 2),
					col = math.floor((editor_width - image_width) / 2),
				}
			end,
		},
	},
}
