return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                marksman = {},
            },
        },
        config = function()
            local lspconfig = require("lspconfig")

            -- Lua LSP
            lspconfig.lua_ls.setup({
                -- Lua LSP 配置
            })

            -- YAML LSP
            lspconfig.yamlls.setup({
                -- YAML LSP 配置
            })

            -- Go LSP
            lspconfig.gopls.setup({
                -- Go LSP 配置
            })

            -- 其他 LSP 配置
            lspconfig.clangd.setup({})
            lspconfig.bashls.setup({})
            lspconfig.pyright.setup({})
            lspconfig.jsonls.setup({})
            lspconfig.dockerls.setup({})
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {
            ensure_installed = { "lua", "python", "bash", "markdown", "yaml", "json", "go", "c", "cpp", "dockerfile" },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<CR>",
                    node_incremental = "<CR>",
                    node_decremental = "<BS>",
                },
            },
        },
    },
}

