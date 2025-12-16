return {
	{
		"hrsh7th/nvim-cmp",
		enabled = true,
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local has_copilot = vim.fn.executable("node") == 1
			
			-- 动态构建补全源
			local sources_group1 = {
				{ 
					name = "nvim_lsp",
					group_index = 1,
					priority = 90,
					max_item_count = 20,
				},
				{ 
					name = "nvim_lua",
					group_index = 1,
					priority = 80,
				},
				{ 
					name = "luasnip",
					group_index = 1,
					priority = 70,
					max_item_count = 5,
				},
			}
			
			-- 如果有 Node.js，在开头添加 Copilot
			if has_copilot then
				table.insert(sources_group1, 1, {
name = "copilot",
group_index = 1,
priority = 100,
max_item_count = 3,
})
			end
			
			-- 动态构建排序比较器
			local comparators = {}
			if has_copilot then
				-- 尝试加载 copilot_cmp，如果失败则使用默认排序
				local ok, copilot_cmp = pcall(require, "copilot_cmp.comparators")
				if ok then
					table.insert(comparators, copilot_cmp.prioritize)
				end
			end
			
			-- 添加默认比较器
			vim.list_extend(comparators, {
cmp.config.compare.offset,
cmp.config.compare.exact,
cmp.config.compare.score,
cmp.config.compare.recently_used,
cmp.config.compare.locality,
cmp.config.compare.kind,
cmp.config.compare.sort_text,
cmp.config.compare.length,
cmp.config.compare.order,
})
			
			cmp.setup({
enabled = true,
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
					["<Down>"] = cmp.mapping(function(fallback)
if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<Up>"] = cmp.mapping(function(fallback)
if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<Tab>"] = cmp.mapping(function(fallback)
if cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							require("luasnip").expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							require("luasnip").jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				-- 补全源配置（按优先级排序）
				sources = cmp.config.sources(sources_group1, {
-- 第二组：低优先级源（第一组没结果才显示）
{ 
name = "buffer",
group_index = 2,
priority = 50,
max_item_count = 10,
option = {
-- 只从可见缓冲区获取
get_bufnrs = function()
								local bufs = {}
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									bufs[vim.api.nvim_win_get_buf(win)] = true
								end
								return vim.tbl_keys(bufs)
							end,
						},
					},
					{ 
						name = "path",
						group_index = 2,
						priority = 40,
					},
				}),
				-- 性能优化
				performance = {
					debounce = 60,
					throttle = 30,
					fetching_timeout = 200,
				},
				-- 实验性功能
				experimental = {
					ghost_text = false,
				},
				-- 排序和过滤
				sorting = {
					priority_weight = 2,
					comparators = comparators,
				},
				-- 补全窗口外观
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				-- 格式化显示
				formatting = {
					format = function(entry, vim_item)
						-- 添加源名称
						vim_item.menu = ({
copilot = "[Copilot]",
nvim_lsp = "[LSP]",
nvim_lua = "[Lua]",
luasnip = "[Snippet]",
buffer = "[Buffer]",
path = "[Path]",
})[entry.source.name]
						return vim_item
					end,
				},
			})
		end,
	},
}
