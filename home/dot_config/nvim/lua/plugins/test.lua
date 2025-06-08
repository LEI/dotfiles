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
    keys = {
      { '<leader>tn', '<cmd>lua require("neotest").run.run()<CR>', desc = 'Run nearest test' },
      { '<leader>tf', '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', desc = 'Run file tests' },
      { '<leader>ts', '<cmd>lua require("neotest").summary.toggle()<CR>', desc = 'Toggle test summary' },
      { '<leader>to', '<cmd>lua require("neotest").output.open({ enter = true })<CR>', desc = 'Open test output' },
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
}
