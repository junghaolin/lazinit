return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        -- 尺寸設定，這裡模擬你原本的 "三分之一屏幕高度"
        size = function(term)
          if term.direction == "horizontal" then
            return math.floor(vim.o.lines / 3)
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<leader>t]], -- 保持你原本的快捷鍵
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2, -- the degree by which to darken to terminal colour
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        persist_size = true,
        direction = "horizontal", -- 預設從下方彈出
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
      })
      
      -- 設定終端模式下的快捷鍵 (類似你原本的 <C-t> 返回 normal mode)
      -- ToggleTerm 推薦使用 <C-\><C-n> 來跳出，但如果你習慣自訂，我們加在這裡
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-t>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end
      
      -- 只有在 TermOpen 時才套用這些快捷鍵
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end
  }
}
