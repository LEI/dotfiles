-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/test/core.lua
return {
  {
    -- Alternatives: David-Kunz/jester, klen/nvim-test, vim-test/vim-test
    'nvim-neotest/neotest',
    -- tag = 'v5.9.1',
    version = 'v5.x',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      -- 'antoinemadec/FixCursorHold.nvim',

      'nvim-treesitter/nvim-treesitter',
      -- nvim-treesitter/nvim-treesitter-textobjects
      -- 'windwp/nvim-ts-autotag',

      {
        'andythigpen/nvim-coverage',
        version = '*',
        opts = {
          auto_reload = true,
        },
      },

      -- Adapters
      -- 'nvim-neotest/neotest-plenary',
      { 'nvim-neotest/neotest-jest', enabled = vim.g.features.node },
      -- { 'V13Axel/neotest-pest', enabled = vim.g.features.php },
      { 'olimorris/neotest-phpunit', enabled = vim.g.features.php },
    },
    -- build = ':TSInstall javascript',
    cmd = 'Neotest',
    -- stylua: ignore
    keys = {
      { '<leader>T', '', desc = '+test' },
      { '<leader>TO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle output panel (Neotest)' },
      { '<leader>TS', function() require('neotest').run.stop() end, desc = 'Stop (Neotest)' },
      { '<leader>TT', function() require('neotest').run.run(vim.uv.cwd()) end, desc = 'Run all test files (Neotest)' },
      { '<leader>Tl', function() require('neotest').run.run_last() end, desc = 'Run last (Neotest)' },
      { '<leader>To', function() require('neotest').output.open({ enter = true, auto_close = true }) end, desc = 'Show output (Neotest)' },
      { '<leader>Tr', function() require('neotest').run.run() end, desc = 'Run nearest (Neotest)' },
      { '<leader>Ts', function() require('neotest').summary.toggle() end, desc = 'Toggle summary (Neotest)' },
      { '<leader>Tt', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run file (Neotest)' },
      { '<leader>Tw', function() require('neotest').watch.toggle(vim.fn.expand('%')) end, desc = 'Toggle watch (Neotest)' },
    },
    opts = {
      adapters = {
        -- 'neotest-plenary',
      },
    },
    config = function(_, opts)
      -- if vim.g.features.go then
      --   local neotest_go = require('neotest-go')({
      --     args = { '-coverprofile=coverage.out' },
      --   })
      --   opts.adapters.neotest_go = neotest_go
      -- end
      if vim.g.features.node then
        local neotest_jest = require('neotest-jest')({
          -- TODO: coverage
          jestCommand = 'npm test --',
          -- jestConfigFile = 'custom.jest.config.ts',
          env = { CI = true },
          -- cwd = function(path)
          --   return vim.fn.getcwd()
          -- end,
        })
        opts.adapters.neotest_jest = neotest_jest
      end
      if vim.g.features.php then
        local neotest_phpunit = require('neotest-phpunit')({
          phpunit_cmd = function()
            -- return 'vendor/bin/phpunit' -- for `dap` strategy then it must return string (table values will cause validation error)
            return { 'composer', 'test', '--' }
          end,
          root_ignore_files = { 'tests/Pest.php' },
          root_files = { 'composer.json', 'phpunit.xml', '.gitignore' },
          filter_dirs = { '.git', 'node_modules', 'vendor' },
          -- env = {}, -- for example {XDEBUG_CONFIG = 'idekey=neotest'}
          -- dap = nil, -- to configure `dap` strategy put single element from `dap.configurations.php`
        })
        opts.adapters.neotest_phpunit = neotest_phpunit
      end
      require('neotest').setup(opts)
    end,
  },
}
