return {
  {
    -- Alternative: nvim-pack/nvim-spectre
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
    tag = 'v9.3.0',
    -- build = ':TSInstall norg',
    dependencies = {
      { 'nvim-neorg/lua-utils.nvim', lazy = true },
      { 'pysan3/pathlib.nvim', lazy = true },
    },
    cmd = 'Neorg', -- :Neorg workspace notes
    ft = 'norg',
    keys = {
      { '<leader>W', '<cmd>Neorg workspace notes<cr>', desc = 'Open notes workspace (Neorg)' },
      { '<leader>P', '<cmd>Neorg presenter start<cr>', desc = 'Start presentation (Neorg)' },

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
    -- vim.wo.foldlevel = 99
    -- vim.wo.conceallevel = 2
  },

  -- stevearc/overseer.nvim
  -- tpope/vim-dispatch

  {
    'vuki656/package-info.nvim',
    tag = '2.0',
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
    tag = 'v4.5.0',
    cmd = 'StartupTime',
    config = function()
      -- How many startup times are averaged
      -- vim.g.startuptime_tries = 10
    end,
  },
}
