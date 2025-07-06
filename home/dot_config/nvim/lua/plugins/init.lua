-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/init.lua
return {
  { 'tpope/vim-sensible', version = '2.0.0', lazy = false },
  { 'MunifTanjim/nui.nvim', tag = '0.4.0', lazy = true },
  { 'nvim-lua/plenary.nvim', tag = 'v0.1.4', lazy = true },
  { 'nvim-neotest/nvim-nio', tag = 'v1.10.1', lazy = true },
  {
    'folke/persistence.nvim',
    tag = 'v3.1.0',
    event = 'BufReadPre',
    opts = {
      -- dir = vim.fn.stdpath('state') .. '/sessions/',
      need = 2, -- Set to 0 to always save
      branch = true, -- Use git branch to save session
    },
    -- stylua: ignore
    keys = {
      { '<leader>S', '', desc = '+session' },
      { '<leader>Sl', function() require('persistence').load({ last = true }) end, desc = 'Restore last session' },
      { '<leader>Sq', function() require('persistence').stop() end, desc = 'Stop persistence' },
      { '<leader>Sr', function() require('persistence').load() end, desc = 'Restore session' },
      { '<leader>Ss', function() require('persistence').select() end,desc = 'Select session' },
    },
    init = function()
      -- Do not restore blank buffers
      vim.opt.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,terminal'
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    tag = 'v8.5.0',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.icons',
    },
    ft = 'markdown',
    opts = {
      completions = { lsp = { enabled = true } },
      file_types = { 'markdown', 'codecompanion', 'Avante' },
      html = { comment = { conceal = false } },
      only_render_image_at_cursor = true,
      preset = 'lazy',
    },
  },
  {
    'HakonHarnes/img-clip.nvim',
    tag = 'v0.6.0',
    cmd = 'PasteImage',
    keys = {
      { '<leader>pi', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    },
    opts = {
      -- Recommended settings
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        -- Required for Windows users
        use_absolute_path = true,
      },
    },
  },
}
