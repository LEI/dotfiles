return {
  {
    'm4xshen/hardtime.nvim',
    -- enabled = false,
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
    -- enabled = false, -- vim.fn.has('nvim-0.8') == 1,
    -- tag = 'v2.1.0',
    version = 'v2.x',
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
    -- tag = 'v1.3',
    version = 'v1.x',
    event = 'CmdlineEnter',
    init = function()
      -- FIXME: <SNR>51_EunuchNewLine
      -- https://github.com/tpope/vim-eunuch/issues/95
      vim.g.eunuch_no_maps = 1
    end,
  },
  {
    'tpope/vim-fugitive',
    -- tag = 'v3.7',
    version = 'v3.x',
    cmd = 'Git',
  },
  {
    'tpope/vim-sleuth',
    -- version = '2.0.0',
    version = '2.x',
    -- FIXME: lazy loading breaks PHP nvim_treesitter#indent()
    -- and GetPhpIndent() neovim/0.11.4/share/nvim/runtime/indent/php.vim:123
    -- cmd = 'Sleuth',
    lazy = false,
    -- init = function()
    --   vim.b.sleuth_automatic = 0
    -- end,
  },
  -- { 'tpope/vim-repeat', version = 'v1.2', event = 'VeryLazy' },
  {
    'nvim-mini/mini.ai',
    -- tag = 'v0.16.0',
    version = 'v0.17.x',
    event = 'InsertEnter',
  },
  {
    'nvim-mini/mini.move',
    -- tag = 'v0.16.0',
    version = 'v0.17.x',
    event = 'InsertEnter',
  },

  -- Alternative: kylechui/nvim-surround
  {
    'tpope/vim-surround',
    -- tag = 'v2.2',
    version = 'v2.x',
    dependencies = { 'tpope/vim-repeat' },
    event = 'VeryLazy',
  },
  -- :h MiniSurround-vim-surround-config
  -- { 'nvim-mini/mini.surround', tag = 'v0.16.0', event = 'InsertEnter' },

  {
    -- Alternative: windwp/nvim-autopairs
    'nvim-mini/mini.pairs',
    -- tag = 'v0.16.0',
    version = 'v0.17.x',
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
    'nvim-treesitter/nvim-treesitter',
    tag = 'v0.10.0',
    dependencies = {
      'RRethy/nvim-treesitter-endwise',
    },
    -- branch = 'main',
    build = ':TSUpdate',
    cmd = {
      'TSBufDisable',
      'TSBufEnable',
      'TSDisable',
      'TSEnable',
      'TSInstall',
      'TSInstallInfo',
      'TSInstallSync',
      'TSModuleInfo',
      'TSUpdate',
      'TSUpdateSync',
    },
    event = 'BufEnter',
    -- lazy = false,
    opts = {
      auto_install = vim.g.config.treesitter.auto_install,
      ensure_installed = vim.g.config.treesitter.ensure_installed
          and {
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
            -- 'norg',
            'python',
            'query',
            'regex',
            'tsx',
            'typescript',
            'vim',
            'vimdoc',
            'yaml',
          }
        or {},

      folds = {
        enabled = true,
      },
      highlight = {
        enable = true,
        disable = function(lang, buf)
          -- Check if 'filetype' option includes 'chezmoitmpl'
          if string.find(vim.bo.filetype, 'chezmoitmpl') then
            return true
          end
          -- Disable slow treesitter highlight for large files
          local max_filesize = 100 * 1024 -- 100 KB
          local fs_stat = (vim.uv or vim.loop).fs_stat
          local ok, stats = pcall(fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      indent = {
        enable = true,
        disable = {
          -- 'php',
        },
      },
      -- sync_install = true,
    },
    init = function()
      vim.opt.foldenable = false
      -- vim.opt.foldlevel = 99
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
      -- https://mise.jdx.dev/mise-cookbook/neovim.html
      require('vim.treesitter.query').add_predicate('is-mise?', function(_, _, bufnr, _)
        local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
        local filename = vim.fn.fnamemodify(filepath, ':t')
        return string.match(filename, '.*mise.*%.toml$') ~= nil
          or string.match(filename, '.*mise.*%.toml%.tmpl$') ~= nil
          or string.match(filepath, '.*mise/config%.toml$') ~= nil
          or string.match(filepath, '.*mise/config%.toml%.tmpl$') ~= nil
      end, { force = true, all = false })
    end,
    config = function(_, opts)
      local configs = require('nvim-treesitter.configs')
      configs.setup(opts)
      -- if opts.folds.enabled then
      --   LazyVim.lsp.on_supports_method('textDocument/foldingRange', function(client, buffer)
      --     local win = vim.api.nvim_get_current_win()
      --     vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      --   end)
      -- end
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    -- tag = 'v1.0.0',
    version = 'v1.x',
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
  -- nvim-mini/mini.comment
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
    enabled = vim.fn.has('nvim-0.10') == 1,
    -- tag = 'v1.5.0',
    version = 'v1.x',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'VeryLazy',
    opts = {
      lang = {
        -- html = '{{-- %s --}}', -- FIXME: blade
      },
    },
  },
  {
    -- WARN: 'windwp/nvim-ts-autotag' breaks dot repeat
    -- https://github.com/windwp/nvim-ts-autotag/issues/166#issuecomment-3138305359
    'tronikelis/ts-autotag.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'InsertEnter', -- 'VeryLazy',
    opts = {},
  },
  {
    'jmbuhr/otter.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    lazy = false,
    config = function()
      -- https://mise.jdx.dev/mise-cookbook/neovim.html
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = {
          'toml',
          -- FIXME: 'toml.chezmoitmpl',
        },
        group = vim.api.nvim_create_augroup('EmbedToml', {}),
        callback = function()
          require('otter').activate()
        end,
      })
    end,
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
    -- tag = 'v2.0.0',
    -- version = 'v2.x',
    -- https://github.com/gbprod/yanky.nvim/pull/184
    branch = 'main',
    dependencies = {
      'folke/snacks.nvim',
      'kkharji/sqlite.lua',
    },
    cmd = 'YankyRingHistory',
    -- event = 'VeryLazy',
    keys = {
      {
        '<leader>pp',
        function()
          vim.cmd('YankyRingHistory')
          -- Snacks.picker.yanky() -- Unreleased
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
      -- system_clipboard = { sync_with_ring = not vim.env.WAYLAND_DISPLAY },
    },
  },
}
