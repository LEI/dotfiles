-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/test/core.lua
return {
  {
    -- Alternatives: David-Kunz/jester, klen/nvim-test, vim-test/vim-test
    'nvim-neotest/neotest',
    tag = 'v5.8.0',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      -- 'antoinemadec/FixCursorHold.nvim',

      'nvim-treesitter/nvim-treesitter',
      -- nvim-treesitter/nvim-treesitter-textobjects
      'windwp/nvim-ts-autotag',

      {
        'andythigpen/nvim-coverage',
        version = '*',
        opts = {
          auto_reload = true,
        },
      },

      -- Adapters
      -- 'nvim-neotest/neotest-plenary',
      'nvim-neotest/neotest-jest',
    },
    -- build = ':TSInstall javascript',
    cmd = 'Neotest',
    -- stylua: ignore
    keys = {
      { '<leader>t', '', desc = '+test' },
      { '<leader>tO', function() require('neotest').output_panel.toggle() end, desc = 'Toggle output panel (Neotest)' },
      { '<leader>tS', function() require('neotest').run.stop() end, desc = 'Stop (Neotest)' },
      { '<leader>tT', function() require('neotest').run.run(vim.uv.cwd()) end, desc = 'Run all test files (Neotest)' },
      { '<leader>tl', function() require('neotest').run.run_last() end, desc = 'Run last (Neotest)' },
      { '<leader>to', function() require('neotest').output.open({ enter = true, auto_close = true }) end, desc = 'Show output (Neotest)' },
      { '<leader>tr', function() require('neotest').run.run() end, desc = 'Run nearest (Neotest)' },
      { '<leader>ts', function() require('neotest').summary.toggle() end, desc = 'Toggle summary (Neotest)' },
      { '<leader>tt', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run file (Neotest)' },
      { '<leader>tw', function() require('neotest').watch.toggle(vim.fn.expand('%')) end, desc = 'Toggle watch (Neotest)' },
    },
    config = function()
      -- local neotest_go = require('neotest-go')({
      --   args = { '-coverprofile=coverage.out' },
      -- })
      local neotest_jest = require('neotest-jest')({
        -- TODO: coverage
        jestCommand = 'npm test --',
        -- jestConfigFile = 'custom.jest.config.ts',
        env = { CI = true },
        -- cwd = function(path)
        --   return vim.fn.getcwd()
        -- end,
      })
      require('neotest').setup({
        adapters = {
          -- 'neotest-plenary',
          -- neotest_go,
          neotest_jest,
        },
      })
    end,
  },
  {
    'mfussenegger/nvim-dap',
    optional = true,
    -- stylua: ignore
    keys = {
      { '<leader>td', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug nearest (Neotest)' },
    },
  },
}
