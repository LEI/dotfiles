-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/init.lua
return {
  { 'tpope/vim-eunuch', tag = 'v1.3', event = 'CmdlineEnter' },
  { 'tpope/vim-fugitive', tag = 'v3.7', cmd = 'Git' },
  { 'tpope/vim-sensible', version = '2.0.0', lazy = false },
  { 'tpope/vim-sleuth', version = '2.0.0', event = 'VeryLazy' },
  { 'tpope/vim-surround', tag = 'v2.2', event = 'VeryLazy' },

  -- Libraries
  { 'MunifTanjim/nui.nvim', tag = '0.4.0', lazy = true },
  { 'nvim-lua/plenary.nvim', tag = 'v0.1.4', lazy = true },
  { 'nvim-neotest/nvim-nio', tag = 'v1.10.1', lazy = true },

  -- Util
  {
    'folke/persistence.nvim',
    tag = 'v3.1.0',
    event = 'BufReadPre',
    opts = {},
    -- stylua: ignore
    keys = {
      { '<leader>Qs', function() require('persistence').load() end, desc = 'Restore Session' },
      { '<leader>QS', function() require('persistence').select() end,desc = 'Select Session' },
      { '<leader>Ql', function() require('persistence').load({ last = true }) end, desc = 'Restore Last Session' },
      { '<leader>Qd', function() require('persistence').stop() end, desc = 'Stop persistence' },
    },
  },
}
