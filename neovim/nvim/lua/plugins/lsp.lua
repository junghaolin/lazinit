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
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Treesitter 配置
            })
        end,
    },
}

