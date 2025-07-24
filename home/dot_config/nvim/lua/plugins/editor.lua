return {
  {
    'm4xshen/hardtime.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    event = 'VeryLazy',
    cmd = 'Hardtime',
    keys = {
      { '<backspace>h', '', desc = '+hardtime' },
      { '<backspace>hd', '<cmd>Hardtime disable<cr>', desc = 'Disable hardtime' },
      { '<backspace>he', '<cmd>Hardtime enable<cr>', desc = 'Enable hardtime' },
      { '<backspace>hr', '<cmd>Hardtime report<cr>', desc = 'Report hardtime' },
      { '<backspace>ht', '<cmd>Hardtime toggle<cr>', desc = 'Toggle hardtime' },
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
    enabled = vim.fn.has('nvim-0.8') == 1,
    tag = 'v2.1.0',
    opts = {
      modes = {
        char = {
          jump_labels = true,
        },
        -- keys = { 'f', 'F', 't', 'T', ';', ',' }, -- TODO: { [';'] = 'L', [','] = H }
      },
    },
    -- stylua: ignore
    keys = {
      'f', 'F', 't', 'T',
      -- ';',
      ',',
      -- { 's', mode = { 'n', 'x', 'o' }, function() require('flash').jump() end, desc = 'Flash' },
      -- { 'S', mode = { 'n', 'x', 'o' }, function() require('flash').treesitter() end, desc = 'Flash treesitter' },
      -- { 'r', mode = 'o', function() require('flash').remote() end, desc = 'Remote flash' },
      -- { 'R', mode = { 'o', 'x' }, function() require('flash').treesitter_search() end, desc = 'Treesitter search' },
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

  -- Alternative: kylechui/nvim-surround
  { 'tpope/vim-surround', tag = 'v2.2', event = 'VeryLazy' },
  -- :h MiniSurround-vim-surround-config
  -- { 'echasnovski/mini.surround', tag = 'v0.16.0', event = 'InsertEnter' },

  {
    -- Alternative: windwp/nvim-autopairs
    'echasnovski/mini.pairs',
    tag = 'v0.16.0',
    event = 'VeryLazy',
    opts = {
      modes = { insert = true, command = false, terminal = false },
      -- skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { 'string' },
      -- skip autopair when next character is closing pair
      -- and there are more closing pairs than opening pairs
      skip_unbalanced = true,
      -- better deal with markdown code blocks
      markdown = true,
    },
  },
  {
    'monaqa/dial.nvim',
    tag = 'v0.4.0',
    keys = { '<C-a>', { '<C-x>', mode = 'n' } },
  },
  {
    'iamcco/markdown-preview.nvim',
    tag = 'v0.0.10',
    -- build = function() vim.fn['mkdp#util#install']() end,
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
    lazy = false,
    cmd = 'Oil',
    opts = {
      columns = {
        'icon',
        'permissions',
        'size',
        'mtime',
      },
      default_file_exporer = true,
      delete_to_trash = true,
      keymaps = {
        ['g?'] = { 'actions.show_help', mode = 'n' },
        ['<CR>'] = 'actions.select',
        -- ['<C-s>'] = { 'actions.select', opts = { vertical = true } },
        -- ['<C-h>'] = { 'actions.select', opts = { horizontal = true } },
        -- ['<C-t>'] = { 'actions.select', opts = { tab = true } },
        ['<C-p>'] = 'actions.preview',
        ['<C-c>'] = { 'actions.close', mode = 'n' },
        ['<M-l>'] = 'actions.refresh', -- Default: C-l
        ['-'] = { 'actions.parent', mode = 'n' },
        ['_'] = { 'actions.open_cwd', mode = 'n' },
        ['`'] = { 'actions.cd', mode = 'n' },
        ['~'] = { 'actions.cd', opts = { scope = 'tab' }, mode = 'n' },
        ['gs'] = { 'actions.change_sort', mode = 'n' },
        ['gx'] = 'actions.open_external',
        ['g.'] = { 'actions.toggle_hidden', mode = 'n' },
        ['g\\'] = { 'actions.toggle_trash', mode = 'n' },
      },
      -- skip_confirm_for_simple_edits = true,
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
      watch_for_changes = true,
    },
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Explore buffer directory' },
      { '<leader>OO', '<cmd>Oil<cr>', desc = 'Open file explorer' },
      { '<leader>OT', '<cmd>TrashOpen<cr>', desc = 'Open system trash' },
    },
    init = function()
      -- FIXME: netrw is required to download spell files
      -- https://github.com/stevearc/oil.nvim/issues/483
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      vim.api.nvim_create_user_command('Trash', function()
        vim.cmd('!trash %')
      end, { desc = 'Trash current file' })

      vim.api.nvim_create_user_command('TrashOpen', function()
        vim.cmd('Oil --trash /')
      end, { desc = 'Open system trash' })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    tag = 'v0.10.0',
    -- branch = 'master',
    lazy = false,
    build = ':TSUpdate',
    -- cmd = { 'TSInstall', 'TSInstallInfo', 'TSInstallSync', 'TSUpdate', 'TSUpdateSync' },
    opts = {
      auto_install = true,
      ensure_installed = {
        'angular',
        'bash',
        'c',
        'dockerfile',
        'hcl',
        -- https://github.com/LazyVim/LazyVim/issues/524
        -- 'help',
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

      highlight = { enable = true },
      indent = { enable = true },
      -- sync_install = true,
    },
    init = function()
      vim.opt.foldenable = false
      vim.opt.foldlevel = 99
      -- vim.wo.conceallevel = 2
      if vim.fn.has('nvim-0.10') == 1 then
        vim.opt.smoothscroll = true
        vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.opt.foldmethod = 'expr'
        vim.opt.foldtext = ''
      else
        vim.opt.foldmethod = 'indent'
        vim.opt.foldtext = 'v:lua.vim.treesitter.foldexpr()'
      end
    end,
    config = function(_, opts)
      local configs = require('nvim-treesitter.configs')
      configs.setup(opts)
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    tag = 'v1.0.0',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    cmd = 'TSContext',
    keys = {
      -- { '[c', function() require('treesitter-context').go_to_context(vim.v.count1) end, desc = 'Go to context', mode = 'n' },
    },
    opts = function()
      local tsc = require('treesitter-context')
      Snacks.toggle({
        name = 'Treesitter Context',
        get = tsc.enabled,
        set = function(state)
          if state then
            tsc.enable()
          else
            tsc.disable()
          end
        end,
      }):map('<leader>ut')
      return {
        mode = 'cursor', -- cursor, topline
        max_lines = 3,
      }
    end,
  },
  -- {
  --   -- select, move, swap, and peek
  --   'nvim-treesitter/nvim-treesitter-textobjects',
  --   dependencies = { 'nvim-treesitter/nvim-treesitter' },
  --   event = 'VeryLazy',
  -- },
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
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
    event = 'VeryLazy',
  },
  {
    'windwp/nvim-ts-autotag',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'InsertEnter',
    opts = {},
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
    'danymat/neogen',
    version = '2.20.0',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    cmd = 'Neogen',
    keys = {
      {
        '<leader>cn',
        function()
          require('neogen').generate()
        end,
        desc = 'Generate annotations (neogen)',
      },
    },
    opts = {},
  },
  {
    'gbprod/yanky.nvim',
    tag = 'v2.0.0',
    dependencies = { 'folke/snacks.nvim' },
    cmd = 'YankyRingHistory',
    -- event = 'VeryLazy',
    keys = {
      {
        '<leader>pp',
        function()
          -- TODO: snacks picker
          -- require('telescope').extensions.yank_history.yank_history({})
          vim.cmd('YankyRingHistory')
        end,
        mode = { 'n', 'x' },
        desc = 'Open Yank History',
      },
      { 'y', '<Plug>(YankyYank)', mode = { 'n', 'x' }, desc = 'Yank Text' },
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Cursor' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Cursor' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'Put Text After Selection' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'Put Text Before Selection' },
      { '[y', '<Plug>(YankyCycleForward)', desc = 'Cycle Forward Through Yank History' },
      { ']y', '<Plug>(YankyCycleBackward)', desc = 'Cycle Backward Through Yank History' },
      { ']p', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[p', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { ']P', '<Plug>(YankyPutIndentAfterLinewise)', desc = 'Put Indented After Cursor (Linewise)' },
      { '[P', '<Plug>(YankyPutIndentBeforeLinewise)', desc = 'Put Indented Before Cursor (Linewise)' },
      { '>p', '<Plug>(YankyPutIndentAfterShiftRight)', desc = 'Put and Indent Right' },
      { '<p', '<Plug>(YankyPutIndentAfterShiftLeft)', desc = 'Put and Indent Left' },
      { '>P', '<Plug>(YankyPutIndentBeforeShiftRight)', desc = 'Put Before and Indent Right' },
      { '<P', '<Plug>(YankyPutIndentBeforeShiftLeft)', desc = 'Put Before and Indent Left' },
      { '=p', '<Plug>(YankyPutAfterFilter)', desc = 'Put After Applying a Filter' },
      { '=P', '<Plug>(YankyPutBeforeFilter)', desc = 'Put Before Applying a Filter' },
    },
    opts = {
      highlight = { timer = 150 },
    },
  },
}
