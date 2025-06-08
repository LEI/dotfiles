local mason_packages_dir = vim.g.home .. '/.local/share/nvim/mason/packages'

return {
  {
    'jay-babu/mason-nvim-dap.nvim',
    tag = 'v2.5.1',
    dependencies = {
      'mason-org/mason.nvim',
    },
    cmd = {
      'DapInstall',
      'DapUninstall',
    },
    opts = {
      -- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
      ensure_installed = {
        'bash', -- bash-debug-adapter
        -- 'chrome', -- chrome-debug-adapter
        -- 'codelldb', -- codelldb
        -- 'coreclr', -- netcoredbg
        'cppdbg', -- cpptools
        -- 'dart', -- dart-debug-adapter
        'delve', -- delve
        -- 'elixir', -- elixir-ls
        -- 'erlang', -- erlang-debugger
        'firefox', -- firefox-debug-adapter
        -- 'haskell', -- haskell-debug-adapter
        -- 'javadbg', -- java-debug-adapter
        -- 'javatest', -- java-test
        'js', -- js-debug-adapter
        -- 'kotlin', -- kotlin-debug-adapter
        -- 'mock', -- mockdebug
        -- 'node2', -- node-debug2-adapter
        'php', -- php-debug-adapter
        -- 'puppet', -- puppet-editor-services
        'python', -- debugpy
      },
      automatic_installation = true,
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,
        js = function(config)
          -- https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md
          -- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
          -- https://code.visualstudio.com/docs/nodejs/nodejs-debugging#_launch-configuration-attributes
          config.adapters = {
            -- type = 'executable',
            -- command = vim.fn.exepath('js-debug-adapter'),
            type = 'server',
            host = 'localhost',
            port = '${port}',
            executable = {
              command = 'node',
              args = { mason_packages_dir .. '/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
            },
          }
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    },
    config = function(_, opts)
      local dap = require('dap')
      require('mason-nvim-dap').setup(opts)
      -- dap.adapters.js,
      local js = {
        {
          type = 'js',
          request = 'launch',
          name = 'JS: Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
      }
      table.insert(dap.configurations.javascript, js)
      table.insert(dap.configurations.javascriptreact, js)
      table.insert(dap.configurations.typescript, js)
      table.insert(dap.configurations.typescriptreact, js)
      -- vim.print('Adapters', dap.adapters, 'Configs', dap.configurations)
    end,
  },
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
    tag = '0.10.0',
    -- https://github.com/igorlfs/nvim-dap-view/issues/84
    -- branch = 'master',
    dependencies = {
      'jay-babu/mason-nvim-dap.nvim',
      'theHamsta/nvim-dap-virtual-text',
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

      { '<leader>dq', '<cmd>DapTerminate<cr>', desc = 'DAP Terminate' },
      -- <leader>b
      { '<leader>db', '<cmd>DapToggleBreakpoint<cr>', desc = 'DAP Toggle Breakpoint' },
      -- <leader>B
      { '<leader>dr', '<cmd>DapToggleRepl<cr>', desc = 'DAP Toggle REPL' },
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
    },
    -- opts = {},
    init = function()
      vim.fn.sign_define('DapBreakpoint', { text = 'B', texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapBreakpointCondition', { text = 'C', texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapLogPoint', { text = 'L', texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapStopped', { text = vim.g.config.signs.pending, texthl = 'ErrorMsg' })
      vim.fn.sign_define('DapBreakpointRejected', { text = 'R', texthl = 'ErrorMsg' })
      local wk = require('which-key')
      wk.add({
        { '<leader>G', name = 'dap' },
      })
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

  --[[ {
    'igorlfs/nvim-dap-view',
    enabled = vim.fn.has('nvim-0.11') == 1,
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
  }, ]]
  --

  {
    'rcarriga/nvim-dap-ui',
    tag = 'v4.0.0',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    cmd = {
      'DapUI',
      -- 'DapUIOpen',
      -- 'DapUIClose',
    },
    keys = {
      { '<leader>dd', '<cmd>DapUI<cr>', desc = 'Toggle DAP UI' },
      -- { '<leader>Go', function() require('dapui').open() end, desc = 'Open DAP UI' },
      -- { '<leader>Gc', function() require('dapui').close() end, desc = 'Close DAP UI' },
    },
    opts = {},
    config = function(_, opts)
      local dapui = require('dapui')
      dapui.setup(opts)
      vim.api.nvim_create_user_command('DapUI', dapui.toggle, { desc = 'Toggle DAP UI' })
    end,
  },
}
