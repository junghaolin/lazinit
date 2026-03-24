return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- 在 LazyVim 中，只需在此處宣告伺服器，Mason 會自動安裝並交由 lspconfig 啟動。
      -- 不需再手動撰寫 config = function() ... lspconfig.setup()。
      servers = {
        marksman = {},
        lua_ls = {},
        yamlls = {},
        gopls = {},
        clangd = {},
        bashls = {},
        pyright = {},
        jsonls = {},
        dockerls = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    -- LazyVim 會自動合併 opts.ensure_installed，因此我們只需加上我們需要的語言。
    opts = {
      ensure_installed = {
        "lua",
        "python",
        "bash",
        "markdown",
        "yaml",
        "json",
        "go",
        "c",
        "cpp",
        "dockerfile",
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
