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
			local neo_tree = require("neo-tree.sources.filesystem.commands")
			local default_open_with_window_picker = neo_tree.open_with_window_picker

			require("neo-tree").setup({
				filesystem = {
					window = {
						mappings = {
							["<cr>"] = "open_with_window_picker",
							["P"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
							["o"] = "system_open",
						},
					},
					commands = {
						open_with_window_picker = function(state)
							local node = state.tree:get_node()
							if node.type == "directory" then
								-- 如果是目錄,使用原始的開合功能
								return default_open_with_window_picker(state)
							elseif node.type == "file" then
								local filepath = node:get_id()

								-- 檢查文件的 MIME 類型
								local mime = vim.fn.system("file --mime-type -b " .. vim.fn.shellescape(filepath))
								mime = vim.fn.trim(mime)

								-- 印出 debug 訊息
								vim.notify("File: " .. filepath .. ", MIME type: " .. mime, vim.log.levels.INFO)

								if vim.startswith(mime, "text/") or vim.startswith(mime, "image/") then
									vim.notify("Opening as text file", vim.log.levels.INFO)
									vim.cmd("edit " .. vim.fn.fnameescape(filepath))
								else
									vim.notify("Opening as binary file", vim.log.levels.INFO)
									-- 確保不在 Neo-tree 窗口
									if vim.bo.filetype == "neo-tree" then
										vim.cmd("wincmd l") -- 切換到下一窗口
									end

									local function read_file_as_hex(filepath, num_bytes)
										local file = io.open(filepath, "rb")
										if not file then
											vim.notify("Cannot open file: " .. filepath, vim.log.levels.ERROR)
											return nil
										end

										local content = file:read(num_bytes or "*a") -- 讀取指定大小的內容或全部
										file:close()

										local hex_output = {}
										local address = 0
										local bytes_per_line = 16 -- 每行顯示的字節數

										for i = 1, #content, bytes_per_line do
											local line_bytes = content:sub(i, i + bytes_per_line - 1)
											local hex_part = {}
											local ascii_part = {}

											-- 格式化每個字節為十六進制和 ASCII
											for j = 1, #line_bytes do
												local byte = line_bytes:byte(j)
												table.insert(hex_part, string.format("%02X", byte)) -- 十六進制部分
												table.insert(
													ascii_part,
													byte >= 32 and byte <= 126 and string.char(byte) or "."
												) -- ASCII 部分
											end

											-- 填充不足 16 字節的部分
											while #hex_part < bytes_per_line do
												table.insert(hex_part, "  ") -- 填充空格
											end

											-- 拼接地址、十六進制部分和 ASCII 部分
											table.insert(
												hex_output,
												string.format(
													"%08X: %s  %s",
													address,
													table.concat(hex_part, " "),
													table.concat(ascii_part)
												)
											)

											address = address + bytes_per_line
										end

										return hex_output -- 確保返回的是一個表
									end

									local hex_lines = read_file_as_hex(filepath, 1024) -- 讀取前 1024 字節
									vim.api.nvim_buf_set_lines(
										0,
										0,
										-1,
										false,
										--vim.split(table.concat(hex_lines, "\n"), "\n")
										hex_lines
									)
									-- 定義高亮樣式
									vim.api.nvim_set_hl(0, "HexAddress", { fg = "#005f87", bold = true }) -- 深藍色
									vim.api.nvim_set_hl(0, "HexZero", { fg = "#505050" }) -- 灰色
									local buf = vim.api.nvim_get_current_buf()
									-- 為每行添加高亮
									for i, line in ipairs(hex_lines) do
										-- 灰色右邊的 `.`
										for start_pos, _ in line:gmatch("()%.") do
											if start_pos > 9 then
												vim.api.nvim_buf_add_highlight(
													buf,
													-1,
													"HexZero",
													i - 1,
													start_pos - 1,
													start_pos
												)
											end
										end
										-- 高亮中間的 `00`
										for start_pos, _ in line:gmatch("()00") do
											if start_pos > 9 then
												vim.api.nvim_buf_add_highlight(
													buf,
													-1,
													"HexZero",
													i - 1,
													start_pos - 1,
													start_pos + 1
												)
											end
										end
										-- 高亮地址部分
										vim.api.nvim_buf_add_highlight(buf, -1, "HexAddress", i - 1, 0, 8)
									end

									vim.cmd("set nomodified") -- 將緩衝區設為未修改狀態
									vim.cmd("set nomodifiable") -- 將緩衝區設為未修改狀態
									vim.cmd("set readonly") -- 將緩衝區設為未修改狀態
								end
							end
						end,

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
	{
		"edluffy/hologram.nvim",
		config = function()
			require("hologram").setup({
				auto_display = true,
			})
		end,
	},
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
