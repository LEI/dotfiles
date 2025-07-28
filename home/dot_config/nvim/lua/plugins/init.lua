-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/init.lua
local sessions_dir = vim.fn.stdpath('state') .. '/sessions/'

return {
  { 'tpope/vim-sensible', version = '2.0.0', lazy = false },
  { 'MunifTanjim/nui.nvim', tag = '0.4.0', lazy = true },
  { 'nvim-lua/plenary.nvim', tag = 'v0.1.4', lazy = true },
  { 'nvim-neotest/nvim-nio', tag = 'v1.10.1', lazy = true },
  {
    'folke/persistence.nvim',
    tag = 'v3.1.0',
    event = 'BufReadPre',
    opts = {
      dir = sessions_dir,
      need = 1, -- Set to 0 to always save
      branch = false, -- Use git branch to save session
    },
    -- stylua: ignore
    keys = {
      { '<leader>S', '', desc = '+session' },
      { '<leader>Sl', function() require('persistence').load({ last = true }) end, desc = 'Restore last session' },
      { '<leader>Sq', function() require('persistence').stop() end, desc = 'Stop persistence' },
      { '<leader>Sr', function() require('persistence').load() end, desc = 'Restore session' },
      { '<leader>Ss', function() require('persistence').select() end,desc = 'Select session' },
    },
    init = function()
      vim.opt.sessionoptions = {
        'blank',
        'buffers',
        'curdir',
        'folds',
        'tabpages',
        'winsize',
        'help',
        'globals',
        'skiprtp',
        'terminal',
      }
      vim.api.nvim_create_user_command('Restore', function()
        require('persistence').load()
      end, { desc = 'Restore session' })
      vim.api.nvim_create_user_command('RestoreLast', function()
        require('persistence').load({ last = true })
      end, { desc = 'Restore last session' })

      -- NOTE: #vim.v.argv == 2 (nvim --embed)
      -- TODO: do not persist if a session already exists in a running instance
      -- to prevent overriding existing sessions when opening a single file

      -- require('persistence').stop()
      -- local msg = 'Stopped persistence: session already exists, started with arguments: '
      --   .. table.concat(vim.v.argv, ' ')
      -- vim.notify(msg, vim.log.levels.WARN)

      -- -- Remove buffers whose files are located outside of cwd
      -- -- https://github.com/folke/persistence.nvim/issues/43
      -- vim.api.nvim_create_autocmd('User', {
      --   pattern = 'PersistenceSavePre',
      --   callback = function()
      --     local cwd = vim.fn.getcwd() .. '/'
      --     for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      --       local bufpath = vim.api.nvim_buf_get_name(buf) .. '/'
      --       if not bufpath:match('^' .. vim.pesc(cwd)) then
      --         vim.api.nvim_buf_delete(buf, {})
      --       end
      --     end
      --   end,
      -- })

      -- Always restore session if one exists
      -- https://github.com/folke/persistence.nvim/issues/13
      vim.api.nvim_create_autocmd('VimEnter', {
        nested = true,
        group = vim.api.nvim_create_augroup('RestoreSession', { clear = true }),
        callback = function()
          local cwd = vim.fn.getcwd()
          -- vim.fn.argc(): number of files in the argument list
          local has_args = (#vim.v.argv > 2) -- FIXME: or vim.g.started_with_stdin
          local session_file = sessions_dir .. cwd:gsub('/', '%%') .. '.vim'
          local session_exists = vim.fn.filereadable(session_file) == 1
          if not has_args and session_exists then
            vim.notify('Loading session: ' .. vim.fn.fnamemodify(cwd, ':~'))
            require('persistence').load()
          elseif has_args and session_exists then
            vim.notify('Stopping persistence (session exists)', vim.log.levels.WARN)
            require('persistence').stop()
          end
        end,
      })
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    tag = 'v8.5.0',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.icons',
    },
    ft = 'markdown',
    opts = {
      code = { enabled = false }, -- FIXME: conceal_delimiters = false
      completions = { lsp = { enabled = true } },
      file_types = { 'markdown', 'codecompanion', 'Avante' },
      html = { comment = { conceal = false } },
      link = { enabled = false },
      only_render_image_at_cursor = true,
      preset = 'lazy',
    },
  },
  {
    'HakonHarnes/img-clip.nvim',
    tag = 'v0.6.0',
    cmd = 'PasteImage',
    keys = {
      { '<leader>pi', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    },
    opts = {
      -- Recommended settings
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        -- Required for Windows users
        use_absolute_path = true,
      },
    },
  },
}
