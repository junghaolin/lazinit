-- Copilot 配置（需要 Node.js）
-- 如果系统没有安装 Node.js，此插件会被自动跳过

-- 检查是否安装了 Node.js
if vim.fn.executable("node") ~= 1 then
	return {}  -- 返回空表，不加载任何插件
end

-- 如果有 Node.js，正常配置插件
return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				panel = {
					enabled = true,
					auto_refresh = true,
					keymap = {
						jump_prev = "[[",
						jump_next = "]]",
						accept = "<CR>",
						refresh = "gr",
						open = "<M-CR>",  -- Alt+Enter
					},
					layout = {
						position = "bottom",
						ratio = 0.4,
					},
				},
				suggestion = {
					enabled = false,  -- 禁用内联建议（使用 copilot-cmp 代替）
				},
				filetypes = {
					yaml = true,
					markdown = true,
					help = false,
					gitcommit = true,
					gitrebase = false,
					hgcommit = false,
					svn = false,
					cvs = false,
					[".."] = false,
				},
				copilot_node_command = "node",
				server_opts_overrides = {
					settings = {
						advanced = {
							listCount = 3,  -- 每次请求 3 个建议
							inlineSuggestCount = 3,
						},
					},
				},
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = {
			"zbirenbaum/copilot.lua",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
