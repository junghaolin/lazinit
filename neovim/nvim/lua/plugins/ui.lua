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
				filesystem = {
					window = {
						mappings = {
							--[[["<cr>"] = "open_with_window_picker",]]
							["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
							["o"] = "system_open",
						},
					},
					commands = {
						system_open = function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							-- 根據你的操作系統使用適當的命令
							vim.fn.jobstart({ "xdg-open", path }, { detach = true }) -- Linux
							-- vim.fn.jobstart({"open", path}, {detach = true})  -- macOS
							-- vim.fn.jobstart({"cmd.exe", "/c", "start", "", path}, {detach = true})  -- Windows
						end,
					},
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
	--[[{
		"edluffy/hologram.nvim",
		config = function()
			require("hologram").setup({
				auto_display = true,
			})
		end,
	},]]
	{
		"3rd/image.nvim",
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
			max_width_window_percentage = nil,
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = false,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			editor_only_render_when_focused = false,
			tmux_show_only_in_active_window = false,
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
		},
	},
}
