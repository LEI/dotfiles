return {
  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = 'VeryLazy',
    cmd = 'Hardtime',
    keys = {
      { '<leader>Hd', '<cmd>Hardtime disable', desc = 'Disable hardtime' },
      { '<leader>He', '<cmd>Hardtime enable', desc = 'Enable hardtime' },
      { '<leader>Hr', '<cmd>Hardtime report', desc = 'Report hardtime' },
      { '<leader>Ht', '<cmd>Hardtime toggle', desc = 'Toggle hardtime' },
    },
    opts = {
      disable_mouse = false,
      disabled_filetypes = {
        lazy = true,
        snacks_picker_input = true,
        -- snacks_picker_list = true,
        -- ['dapui*'] = false,
      },
      disabled_keys = {
        -- ['<Up>'] = false, -- Allow <Up> key
        -- ['<Space>'] = { 'n', 'x' }, -- Disable <Space> key in normal and visual mode
      },
      restriction_mode = 'hint', -- Default: block
    },
  },
  {
    'folke/flash.nvim',
    enabled = false, -- vim.fn.has('nvim-0.8') == 1,
    tag = 'v2.1.0',
    opts = {},
    -- stylua: ignore
    keys = {
      { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
      { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote flash' },
      { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter search' },
      { '<c-s>', mode = { 'c' }, function() require('flash').toggle() end, desc = 'Toggle Flash search' },
    },
  },

  -- { 'tpope/vim-dotenv', tag = 'v1.0', cmd = 'Dotenv' },
  {
    'tpope/vim-eunuch',
    tag = 'v1.3',
    event = 'CmdlineEnter',
    init = function()
      -- FIXME: <SNR>51_EunuchNewLine
      -- https://github.com/tpope/vim-eunuch/issues/95
      vim.g.eunuch_no_maps = 1
    end,
  },
  { 'tpope/vim-fugitive', tag = 'v3.7', cmd = 'Git' },
  { 'tpope/vim-sleuth', version = '2.0.0', event = 'VeryLazy' },
  -- { 'tpope/vim-repeat', version = 'v1.2', event = 'VeryLazy' },
  { 'tpope/vim-surround', tag = 'v2.2', event = 'VeryLazy' },
  {
    'echasnovski/mini.ai',
    tag = 'v0.16.0',
    event = 'InsertEnter',
  },
  {
    'echasnovski/mini.move',
    tag = 'v0.16.0',
    event = 'InsertEnter',
  },
  -- :h MiniSurround-vim-surround-config
  -- { 'echasnovski/mini.surround', tag = 'v0.16.0', event = 'InsertEnter' },
  {
    -- Alternative: 'windwp/nvim-autopairs',
    'echasnovski/mini.pairs',
    tag = 'v0.16.0',
    event = 'InsertEnter',
    opts = {},
  },
  {
    'monaqa/dial.nvim',
    tag = 'v0.4.0',
    keys = { '<C-a>', { '<C-x>', mode = 'n' } },
  },
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
        -- once = true,
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
    -- branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    opts = {
      auto_install = true,
      ensure_installed = {
        'angular',
        'bash',
        'c',
        'dockerfile',
        'hcl',
        'help',
        'html',
        'javascript',
        'json',
        'jsonc',
        'lua',
        'markdown',
        'markdown_inline',
        'norg',
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
    init = function()
      vim.wo.foldenable = false
      vim.wo.foldmethod = 'expr'
      vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'VeryLazy',
  },
  -- echasnovski/mini.comment
  -- options = {
  --   custom_commentstring = function()
  --     return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
  --   end,
  -- },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    enabled = vim.fn.has('nvim-0.10') == 1,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'VeryLazy',
    opts = {
      enable_autocmd = false,
    },
    init = function()
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == 'commentstring' and require('ts_context_commentstring.internal').calculate_commentstring()
          or get_option(filetype, option)
      end
    end,
  },
  {
    'folke/ts-comments.nvim',
    enabled = false, -- vim.fn.has('nvim-0.10') == 1,
    tag = 'v1.5.0',
    opts = {},
    event = 'VeryLazy',
  },
  -- gbprod/yanky.nvim
}
