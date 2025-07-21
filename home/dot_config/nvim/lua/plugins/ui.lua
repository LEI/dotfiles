local spinner = vim.g.config.signs.spinner
-- local spinner_len = #spinner

vim.diagnostic.config({
  float = {
    source = true, -- 'if_many',
  },
  severity_sort = true,
  signs = {
    text = vim.g.diagnostic_signs,
    -- linehl = {
    --   [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
    -- },
    -- numhl = {
    --   [vim.diagnostic.severity.WARN] = 'WarningMsg',
    -- },
  },
  virtual_text = {
    source = 'if_many',
    prefix = '●',
  },
})

-- https://github.com/stevearc/aerial.nvim
-- require('aerial').setup()

-- require('bufferline').setup()

return {
  -- Alternative: ecthelionvi/NeoColumn.nvim
  -- {
  --   'Bekaboo/deadcolumn.nvim',
  --   tag = 'v1.0.2',
  --   opts = {
  --     modes = function()
  --       return true
  --     end,
  --     extra = { follow_tw = '+1' },
  --   },
  --   init = function()
  --     vim.api.nvim_create_autocmd('BufEnter', {
  --       pattern = '*',
  --       command = 'setlocal colorcolumn=120',
  --     })
  --   end,
  -- },
  {
    'm4xshen/smartcolumn.nvim',
    tag = 'v1.1.1',
    event = 'VeryLazy',
    opts = {
      colorcolumn = '80',
      disabled_filetypes = {
        'Trouble',
        'checkhealth',
        'fish',
        'help',
        'lazy',
        'lspinfo',
        'markdown',
        'mason',
        'noice',
        'snacks_dashboard',
        'text',
        'zsh',
      },
      scope = 'file', -- file, window or line
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'folke/snacks.nvim' },
    tag = 'v1.0.2',
    cmd = 'Gitsigns',
    event = {
      -- 'CursorHold',
      'VeryLazy',
    },
    -- stylua: ignore
    keys = {
      -- { '<leader>gh', desc = '+hunks' },
      { '<leader>gh', '<cmd>Gitsigns setqflist<cr>', desc = 'Git hunks (QF list)' },
      { ')h', '<cmd>Gitsigns next_hunk<cr>', desc = 'Next hunk', mode = { 'n', 'v' } },
      { '(h', '<cmd>Gitsigns prev_hunk<cr>', desc = 'Next hunk', mode = { 'n', 'v' } },
    },
    opts = function()
      Snacks.toggle({
        name = 'Git Signs',
        get = function()
          return require('gitsigns.config').config.signcolumn
        end,
        set = function(state)
          require('gitsigns').toggle_signs(state)
        end,
      }):map('<leader>uG')
      return {
        current_line_blame = true,
      }
    end,
  },

  {
    'folke/todo-comments.nvim',
    -- NOTE: snacks todo comments not released yet
    branch = 'main',
    -- tag = 'v1.4.0',
    dependencies = {
      'folke/snacks.nvim',
      'nvim-lua/plenary.nvim',
    },
    cmd = {
      -- 'TodoFzfLua',
      -- 'TodoLocList',
      -- 'TodoQuickFix',
      -- 'TodoTelescope',
      'TodoTrouble',
    },
    event = {
      -- 'CursorHold',
      'VeryLazy',
    },
    -- stylua: ignore
    keys = {
      { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
      { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
      -- { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme (Trouble)' },
      -- { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
      -- { '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = 'Todo/Fix/Fixme' },
      -- { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
      -- { '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = 'Todo/Fix/Fixme' },
      { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
      { '<leader>sT', function() Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIX', 'FIXME' } }) end, desc = 'Todo/Fix/Fixme' },
    },
    opts = {
      signs = true,
    },
  },

  {
    'folke/trouble.nvim',
    tag = 'v3.7.1',
    cmd = 'Trouble',
    opts = {},
    -- event = 'CursorHold',
    keys = {
      { '<leader>x', '', desc = '+diagnostics/quickfix' },
      { '<leader>X', '<cmd>Trouble<cr>', desc = 'Trouble', mode = { 'n', 'v' } },
      { '<leader>xs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)', mode = { 'n', 'v' } },
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
    init = function()
      -- -- Automatically open Trouble quickfix
      -- -- FIXME: No results for **qflist**
      -- vim.api.nvim_create_autocmd('QuickFixCmdPost', {
      --   callback = function()
      --     vim.cmd('Trouble qflist open')
      --   end,
      -- })
      -- vim.api.nvim_create_autocmd('DiagnosticChanged', {
      --   callback = function()
      --     if vim.diagnostic.get(0) and #vim.diagnostic.get(0) > 0 then
      --       vim.cmd('Trouble diagnostics open')
      --     end
      --   end,
      -- })
    end,
  },
}
