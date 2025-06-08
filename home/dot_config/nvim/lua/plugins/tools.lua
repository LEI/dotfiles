return {
  {
    'xvzc/chezmoi.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    cmd = { 'ChezmoiEdit', 'ChezmoiList' },
    opts = {},
    init = function(_, opts)
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = {
          vim.g.home .. '/.dotfiles/home',
          vim.g.home .. '/.local/share/chezmoi/home/*',
          vim.g.home .. '/src/*/*/dotfiles/home',
        },
        callback = function(ev)
          local bufnr = ev.buf
          local edit_watch = function()
            require('chezmoi.commands.__edit').watch(bufnr)
          end
          vim.schedule(edit_watch)
        end,
      })
    end,
  },

  -- Search and replace: MagicDuck/grug-far.nvim, nvim-pack/nvim-spectre

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
          -- if not package.loaded['package-info'] then
          --   require('package-info').setup({ autostart = false })
          -- end
          require('which-key').add({
            { '<leader>n', group = 'notifications/npm', buffer = 0 },
            { '<leader>ns', '<cmd>PackageInfo<cr>', desc = 'Show package info', buffer = 0 },
            { '<leader>nS', '<cmd>PackageInfo!<cr>', desc = 'Refresh package info', buffer = 0 },
            { '<leader>nd', '<cmd>PackageDelete<cr>', desc = 'Delete dependency', buffer = 0 },
            { '<leader>np', '<cmd>PackageChangeVersion<cr>', desc = 'Install different version', buffer = 0 },
            { '<leader>ni', '<cmd>PackageInstall<cr>', desc = 'Install new dependency', buffer = 0 },
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
