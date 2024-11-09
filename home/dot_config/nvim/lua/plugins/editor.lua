return {
  {
    -- Alternative: echasnovski/mini.pairs
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },
  -- monaqa/dial.nvim
  {
    'iamcco/markdown-preview.nvim',
    tag = 'v0.0.10',
    -- build = function() vim.fn["mkdp#util#install"]() end,
    build = 'cd app && yarn install --frozen-lockfile',
    cmd = {
      'MarkdownPreview',
      'MarkdownPreviewStop',
      'MarkdownPreviewToggle',
    },
    ft = { 'markdown' },
    init = function()
      -- vim.g.mkdp_filetypes = { 'markdown' }
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { 'markdown' },
        once = true,
        callback = function()
          require('which-key').add({
            { '<leader>m', group = 'markdown', buffer = 0 },
            { '<leader>mp', '<cmd>MarkdownPreview<cr>', desc = 'Markdown Preview', buffer = 0 },
            { '<leader>ms', '<cmd>MarkdownPreviewStop<cr>', desc = 'Markdown Preview Stop', buffer = 0 },
            { '<leader>mt', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown Preview Toggle', buffer = 0 },
          })
        end,
      })
    end,
  },
  {
    'stevearc/oil.nvim',
    version = '2.15.0',
    cmd = 'Oil',
    opts = {
      delete_to_trash = false,
      keymaps = {
        ['g?'] = { 'actions.show_help', mode = 'n' },
        ['<CR>'] = 'actions.select',
        -- ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
        -- ['<C-h>'] = { 'actions.select', opts = { horizontal = true } },
        -- ['<C-t>'] = { 'actions.select', opts = { tab = true } },
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = { 'actions.close', mode = 'n' },
        -- ['<C-l>'] = 'actions.refresh',
        ['-'] = { 'actions.parent', mode = 'n' },
        ['_'] = { 'actions.open_cwd', mode = 'n' },
        ['`'] = { 'actions.cd', mode = 'n' },
        ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
        ['gs'] = { 'actions.change_sort', mode = 'n' },
        ['gx'] = 'actions.open_external',
        ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
        ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { '<leader>O', '<cmd>Oil<cr>', desc = 'Oil' },
    },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    -- stylua: ignore
    keys = {
      { '<leader>r', '', desc = '+refactor' },
      { '<leader>re', function() return require('refactoring').refactor('Extract Function') end, desc = 'Extract Function (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>rf', function() return require('refactoring').refactor('Extract Function To File') end, desc = 'Extract Function To File (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>rv', function() return require('refactoring').refactor('Extract Variable') end, desc = 'Extract Variable (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>rI', function() return require('refactoring').refactor('Inline Function') end, desc = 'Inline Function (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>ri', function() return require('refactoring').refactor('Inline Variable') end, desc = 'Inline Variable (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>rR', function() return require('refactoring').refactor('Extract Block') end, desc = 'Extract Block (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>rb', function() return require('refactoring').refactor('Extract Block To File') end, desc = 'Extract Block To File (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>rB', function() return require('refactoring').refactor('Extract Block To Buffer') end, desc = 'Extract Block To Buffer (Refactor)', expr = true, mode = { 'n', 'x' } },
      { '<leader>rr', function() return require('refactoring').select_refactor() end, desc = 'Select (Refactor)', expr = true, mode = { 'n', 'x' } },
    },
    -- lazy = false,
    opts = {
      show_success_message = true,
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    tag = 'v0.10.0',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    opts = {
      auto_install = true,
      -- ensure_installed = 'all',
      ensure_installed = {
        'angular',
        'bash',
        'c',
        'help',
        'html',
        'javascript',
        'json',
        'jsonc',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      highlight = {
        enable = true,
      },
    },
  },
  {
    'folke/ts-comments.nvim',
    tag = 'v1.5.0',
    opts = {},
    event = 'VeryLazy',
    enabled = vim.fn.has('nvim-0.10.0') == 1,
  },
  -- gbprod/yanky.nvim
}
