return {
  {
    -- Alternative: nvim-pack/nvim-spectre, scooter
    'MagicDuck/grug-far.nvim',
    cmd = { 'GrugFar', 'GrugFarWithin' },
    keys = {
      { '<leader>G', '<cmd>GrugFar<cr>', desc = 'Search and replace (GrugFar)' },
    },
    opts = {},
  },

  -- jbyuki/venn.nvim
  {
    -- Alternatives: nvim-orgmode/orgmode, zk-org/zk
    'nvim-neorg/neorg',
    enabled = false,
    -- tag = 'v9.3.0',
    version = 'v9.x',
    -- build = ':TSInstall norg',
    dependencies = {
      { 'nvim-neorg/lua-utils.nvim', lazy = true },
      { 'pysan3/pathlib.nvim', lazy = true },
    },
    cmd = 'Neorg', -- :Neorg workspace notes
    ft = 'norg',
    keys = {
      -- { '<leader>W', '<cmd>Neorg workspace notes<cr>', desc = 'Open notes workspace (Neorg)' },
      -- { '<leader>P', '<cmd>Neorg presenter start<cr>', desc = 'Start presentation (Neorg)' },

      -- neorg.presenter.next-page - go to next page
      -- neorg.presenter.previous-page - go to previous page
      -- neorg.presenter.close - close presentation view
    },
    opts = {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = {},
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/notes',
            },
            default_workspace = 'notes',
          },
        },
        ['core.journal'] = { config = { strategy = 'flat' } },
        ['core.keybinds'] = { config = { default_keybinds = true } },
        ['core.presenter'] = { config = { ['zen_mode'] = 'zen-mode' } },
      },
    },
  },

  -- Vigemus/iron.nvim
  {
    'tpope/vim-dispatch',
    enabled = false,
    -- version = 'v1.8',
    version = 'v1.x',
    cmd = {
      'Copen',
      'Dispatch',
      'Make',
      'Spawn',
      'Start',
    },
    keys = {
      { '<leader>D', '<cmd>Dispatch<cr>', desc = 'Dispatch command' },
    },
  },
  -- laktak/tome
  {
    'stevearc/overseer.nvim',
    -- enabled = false,
    version = 'v2.x',
    dependencies = { 'folke/persistence.nvim' },
    cmd = {
      'OverseerBuild',
      'OverseerClearCache',
      'OverseerClose',
      'OverseerDeleteBundle',
      'OverseerInfo',
      'OverseerLoadBundle',
      'OverseerOpen',
      'OverseerQuickAction',
      'OverseerRun',
      'OverseerRunCmd',
      'OverseerSaveBundle',
      'OverseerTaskAction',
      'OverseerToggle',
    },
    opts = {
      dap = false,
      task_list = {
        bindings = {
          ['<C-h>'] = false,
          ['<C-j>'] = false,
          ['<C-k>'] = false,
          ['<C-l>'] = false,
        },
      },
      -- form = { win_opts = { winblend = 0 } },
      -- confirm = { win_opts = { winblend = 0 } },
      -- task_win = { win_opts = { winblend = 0 } },
      templates = {
        'builtin',
        -- https://github.com/stevearc/overseer.nvim/pull/414
        'mise',
        'scripts',
      },
      components = {
        { 'on_complete_dispose', timeout = 0 },
      },
    },
    keys = {
      { '<leader>o', '', desc = '+overseer' },
      { '<leader>ow', '<cmd>OverseerToggle<cr>', desc = 'Task list' },
      { '<leader>oo', '<cmd>OverseerRun<cr>', desc = 'Run task' },
      { '<leader>oq', '<cmd>OverseerQuickAction<cr>', desc = 'Action recent task' },
      { '<leader>oi', '<cmd>OverseerInfo<cr>', desc = 'Overseer info' },
      { '<leader>ob', '<cmd>OverseerBuild<cr>', desc = 'Task builder' },
      { '<leader>ot', '<cmd>OverseerTaskAction<cr>', desc = 'Task action' },
      { '<leader>oc', '<cmd>OverseerClearCache<cr>', desc = 'Clear cache' },
      { '<leader>ol', '<cmd>OverseerRestartLast<cr>', desc = 'Restart last' },
    },
    -- lazy = false,
    init = function()
      -- Restart last task
      vim.api.nvim_create_user_command('OverseerRestartLast', function()
        local overseer = require('overseer')
        local tasks = overseer.list_tasks({ recent_first = true })
        if vim.tbl_isempty(tasks) then
          vim.notify('No tasks found', vim.log.levels.WARN)
        else
          overseer.run_action(tasks[1], 'restart')
        end
      end, {})

      -- :Make similar to vim-dispatch
      vim.api.nvim_create_user_command('Make', function(params)
        -- Insert args at the '$*' in the makeprg
        local cmd, num_subs = vim.o.makeprg:gsub('%$%*', params.args)
        if num_subs == 0 then
          cmd = cmd .. ' ' .. params.args
        end
        local task = require('overseer').new_task({
          cmd = vim.fn.expandcmd(cmd),
          components = {
            { 'on_output_quickfix', open = not params.bang, open_height = 8 },
            'default',
          },
        })
        task:start()
      end, {
        desc = 'Run your makeprg as an Overseer task',
        nargs = '*',
        bang = true,
      })

      -- Asynchronous :Grep command
      vim.api.nvim_create_user_command('Grep', function(params)
        -- Insert args at the '$*' in the grepprg
        local cmd, num_subs = vim.o.grepprg:gsub('%$%*', params.args)
        if num_subs == 0 then
          cmd = cmd .. ' ' .. params.args
        end
        local task = require('overseer').new_task({
          cmd = vim.fn.expandcmd(cmd),
          components = {
            {
              'on_output_quickfix',
              errorformat = vim.o.grepformat,
              open = not params.bang,
              open_height = 8,
              items_only = true,
            },
            -- We don't care to keep this around as long as most tasks
            { 'on_complete_dispose', timeout = 30 },
            'default',
          },
        })
        task:start()
      end, { nargs = '*', bang = true, complete = 'file' })
    end,
  },

  {
    'vuki656/package-info.nvim',
    -- tag = '2.0',
    version = 'v2.x',
    dependencies = { 'MunifTanjim/nui.nvim' },
    lazy = true,
    cmd = { 'PackageInfo', 'PackageDelete', 'PackageChangeVersion', 'PackageInstall' },
    -- event = { 'BufReadPre package.json' },
    opts = {
      autostart = false,
      hide_unstable_versions = false,
      hide_up_to_date = false,
      package_manager = 'npm',
    },
    config = function(_, opts)
      require('package-info').setup(opts)
      vim.api.nvim_create_user_command('PackageInfo', function(args)
        require('package-info').show({ force = args.bang })
      end, { desc = 'Show package info', bang = true })
      vim.api.nvim_create_user_command('PackageDelete', function()
        require('package-info').delete()
      end, { desc = 'Delete dependency' })
      vim.api.nvim_create_user_command('PackageChangeVersion', function()
        require('package-info').change_version()
      end, { desc = 'Install different version' })
      vim.api.nvim_create_user_command('PackageInstall', function()
        require('package-info').install()
      end, { desc = 'Install new dependency' })
    end,
    init = function()
      vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
        pattern = { 'package.json' },
        once = true,
        callback = function()
          require('which-key').add({
            { '<leader>p', group = 'package-info', buffer = 0 },
            { '<leader>ps', '<cmd>PackageInfo<cr>', desc = 'Show package info', buffer = 0 },
            { '<leader>pS', '<cmd>PackageInfo!<cr>', desc = 'Refresh package info', buffer = 0 },
            { '<leader>pd', '<cmd>PackageDelete<cr>', desc = 'Delete dependency', buffer = 0 },
            { '<leader>pp', '<cmd>PackageChangeVersion<cr>', desc = 'Install different version', buffer = 0 },
            { '<leader>pi', '<cmd>PackageInstall<cr>', desc = 'Install new dependency', buffer = 0 },
          })
        end,
      })
    end,
  },
  {
    'dstein64/vim-startuptime',
    -- tag = 'v4.5.0',
    version = 'v4.x',
    cmd = 'StartupTime',
    config = function()
      -- How many startup times are averaged
      -- vim.g.startuptime_tries = 10
    end,
  },
}
