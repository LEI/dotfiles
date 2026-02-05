return {
  {
    'stevearc/oil.nvim',
    -- FIXME: must be disabled once to download spell files via netrw
    enabled = vim.g.config.explorer == 'oil',
    -- https://github.com/stevearc/oil.nvim/pull/591
    branch = 'master',
    -- version = '2.15.0',
    -- lazy = false,
    cmd = 'Oil',
    -- https://github.com/stevearc/oil.nvim/issues/300
    -- event = { 'BufNew */*,.*', 'VimEnter */*,.*' },
    lazy = false,
    opts = {
      columns = {
        'icon',
        -- 'permissions',
        -- 'size',
        -- 'mtime',
      },
      -- WARN: this replaces netrw and breaks scp://
      default_file_explorer = false, -- true, -- not vim.opt.spelllang,
      delete_to_trash = true,
      keymaps = {
        ['g?'] = { 'actions.show_help', mode = 'n' },
        ['gd'] = {
          desc = 'Toggle file detail view',
          callback = function()
            vim.g.oil_detail = not vim.g.oil_detail
            if vim.g.oil_detail then
              require('oil').set_columns({ 'icon', 'permissions', 'size', 'mtime' })
            else
              require('oil').set_columns({ 'icon' })
            end
          end,
        },
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
      win_options = {
        signcolumn = 'yes:2',
      },
    },
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Explore buffer directory' },
      { '<leader>OO', '<cmd>Oil<cr>', desc = 'Open file explorer' },
      { '<leader>OT', '<cmd>TrashOpen<cr>', desc = 'Open system trash' },
    },
    init = function()
      -- NOTE: netrw is required to download spell files

      -- https://github.com/stevearc/oil.nvim/issues/483
      -- vim.g.loaded_netrw = 1
      -- vim.g.loaded_netrwPlugin = 1

      -- https://neovim.io/doc/user/spell.html#_spell-file-missing
      -- :au SpellFileMissing * call Download_spell_file(expand('<amatch>'))
      -- vim.g.loaded_spellfile_plugin = 1
      -- vim.api.nvim_create_autocmd('SpellFileMissing', {
      --   pattern = '*',
      --   callback = function(args) vim.call('Download_spell_file', args.match) end,
      -- })

      vim.api.nvim_create_user_command('Trash', function()
        vim.cmd('!trash %')
      end, { desc = 'Trash current file' })

      vim.api.nvim_create_user_command('TrashOpen', function()
        vim.cmd('Oil --trash /')
      end, { desc = 'Open system trash' })
    end,
  },
  {
    'refractalize/oil-git-status.nvim',
    dependencies = { 'stevearc/oil.nvim' },
    event = { 'BufEnter oil://*', 'BufWinEnter oil://*' },
    opts = {
      show_ignored = true,
    },
  },
}
