return {
  {
    'theHamsta/nvim-dap-virtual-text',
    -- tag = '*',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    lazy = true,
    opts = {
      -- show_stop_reason = false,
    },
  },
  -- Alternative: puremourning/vimspector
  {
    -- https://codeberg.org/mfussenegger/nvim-dap
    'mfussenegger/nvim-dap',
    -- FIXME: attempt to concatenate local 'text' (multiple adapters)
    -- ~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/select.lua:19
    tag = '0.10.0', -- nvim 0.9.5
    -- NOTE: attempt to index field 'on_session'
    -- https://github.com/igorlfs/nvim-dap-view/issues/84
    -- branch = 'master',
    dependencies = {
      'jay-babu/mason-nvim-dap.nvim',
      'theHamsta/nvim-dap-virtual-text',

      -- 'mfussenegger/nvim-dap-python',
    },
    cmd = {
      'DapContinue',
      'DapEval',
      'DapNew',
      'DapToggleBreakpoint',
      'DapToggleRepl',
    },
    keys = {
      -- { '<F5>', '<cmd>DapContinue<cr>', desc = 'Run last (DAP Continue)' },
      -- { '<F10>', '<cmd>DapStepOver<cr>', desc = 'DAP Step Over' },
      -- { '<F11>', '<cmd>DapStepInto<cr>', desc = 'DAP Step Into' },
      -- { '<F12>', '<cmd>DapStepOut<cr>', desc = 'DAP Step Out' },

      { '<leader>d', '', desc = '+debug' },
      { '<leader>dq', '<cmd>DapTerminate<cr>', desc = 'DAP Terminate' },
      { '<leader>db', '<cmd>DapToggleBreakpoint<cr>', desc = 'DAP Toggle Breakpoint' }, -- <leader>b
      { '<leader>dr', '<cmd>DapToggleRepl<cr>', desc = 'DAP Toggle REPL' }, -- <leader>B
      {
        '<leader>dl', -- <leader>lp
        function()
          require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
        end,
        desc = 'DAP Log Point',
      },
      { '<leader>dL', '<cmd>DapShowLog<cr>', desc = 'DAP Show Log' },
      { '<leader>dc', '<cmd>DapContinue<cr>', desc = 'Run last (DAP Continue)' },
      { '<leader>ds', '<cmd>DapStepOver<cr>', desc = 'DAP Step Over' },
      { '<leader>di', '<cmd>DapStepInto<cr>', desc = 'DAP Step Into' },
      { '<leader>do', '<cmd>DapStepOut<cr>', desc = 'DAP Step Out' },

      {
        '<leader>dh',
        function()
          require('dap.ui.widgets').hover()
        end,
        desc = 'DAP Hover',
      },
      {
        '<leader>dp',
        function()
          require('dap.ui.widgets').preview()
        end,
        desc = 'DAP Preview',
      },
      {
        '<leader>df',
        function()
          require('dap.ui.widgets').centered_float(require('dap.ui.widgets').frames)
        end,
        desc = 'DAP Frames',
      },
      {
        '<leader>ds',
        function()
          require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)
        end,
        desc = 'DAP Scopes',
      },

      -- nvim-neotest/neotest
      {
        '<leader>Td',
        function()
          require('neotest').run.run({ strategy = 'dap' })
        end,
        desc = 'Debug nearest (Neotest)',
      },
    },
    -- opts = {},
    init = function()
      vim.fn.sign_define('DapBreakpoint', { text = 'B', texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapBreakpointCondition', { text = 'C', texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapLogPoint', { text = 'L', texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapStopped', { text = vim.g.config.signs.pending, texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapBreakpointRejected', { text = 'R', texthl = 'ErrorMsg' })
      vim.api.nvim_create_user_command('DAP', function()
        vim.cmd('DapToggleBreakpoint')
        vim.cmd('DapContinue')
      end, { desc = 'DAP toogle breakpoint and continue' })
    end,
    --[[ config = function(_, opts)
      local dap = require('dap')

      -- https://github.com/microsoft/vscode-js-debug
      -- dap.adapters['pwa-node'] = {
      --   type = 'server',
      --   host = 'localhost',
      --   port = '${port}',
      --   executable = {
      --     command = 'node',
      --     args = { mason_packages_dir .. '/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
      --   },
      -- }
      -- local pwa_node = {
      --   {
      --     type = 'pwa-node',
      --     request = 'launch',
      --     name = 'Launch file',
      --     program = '${file}',
      --     cwd = '${workspaceFolder}',
      --   },
      -- }
      -- dap.configurations.javascript = pwa_node
      -- dap.configurations.javascriptreact = pwa_node

      -- https://github.com/firefox-devtools/vscode-firefox-debug
      -- dap.adapters.firefox = {
      --   type = 'executable',
      --   command = 'node',
      --   args = { mason_packages_dir .. '/firefox-debug-adapter/dist/adapter.bundle.js' },
      -- }
      -- local firefox = {
      --   {
      --     name = 'Debug with Firefox',
      --     type = 'firefox',
      --     request = 'launch',
      --     reAttach = true,
      --     url = 'http://localhost:3000',
      --     webRoot = '${workspaceFolder}',
      --     firefoxExecutable = '/usr/bin/firefox',
      --   },
      -- }
      -- dap.configurations.typescript = firefox
      -- dap.configurations.typescriptreact = firefox
    end, --]]
  },

  {
    'igorlfs/nvim-dap-view',
    enabled = false, -- vim.fn.has('nvim-0.11') == 1,
    -- branch = 'main',
    -- commit = '280213a',
    dependencies = { 'mfussenegger/nvim-dap' },
    cmd = {
      'DapViewJump',
      'DapViewOpen', -- Close
      'DapViewShow',
      'DapViewToggle',
      'DapViewWatch',
      'DapViewWatch',
    },
    keys = {
      { '<leader>dv', '<cmd>DapViewToggle<cr>', desc = 'Open DAP view' },
    },
    ---@module 'dap-view'
    ---@type dapview.Config
    opts = {},
  },

  {
    'rcarriga/nvim-dap-ui',
    tag = 'v4.0.0',
    dependencies = {
      'mfussenegger/nvim-dap',
      { 'nvim-neotest/nvim-nio', version = 'v1.x' },
    },
    cmd = {
      'DapUI',
      -- 'DapUIOpen',
      -- 'DapUIClose',
    },
    keys = {
      { '<leader>dd', '<cmd>DapUI<cr>', desc = 'Toggle DAP UI' },
      -- { '<leader>dO', function() require('dapui').open() end, desc = 'Open DAP UI' },
      -- { '<leader>dC', function() require('dapui').close() end, desc = 'Close DAP UI' },
    },
    opts = {},
    config = function(_, opts)
      local dapui = require('dapui')
      dapui.setup(opts)
      vim.api.nvim_create_user_command('DapUI', dapui.toggle, { desc = 'Toggle DAP UI' })
    end,
  },
}
