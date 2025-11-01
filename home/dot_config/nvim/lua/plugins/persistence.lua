return {
  {
    'folke/persistence.nvim',
    -- tag = 'v3.1.0',
    version = 'v3.x',
    event = 'BufReadPre',
    opts = {
      dir = vim.g.sessions_dir,
      need = 1, -- Set to 0 to always save
      branch = false, -- Use git branch to save session
    },
    -- stylua: ignore
    keys = {
      { '<leader>S', '', desc = '+session' },
      { '<leader>Sl', function() require('persistence').load({ last = true }) end, desc = 'Restore last session' },
      { '<leader>Sq', '<cmd>Stop<cr>', desc = 'Stop persistence' },
      { '<leader>Sr', function() require('persistence').load() end, desc = 'Restore session' },
      { '<leader>Ss', function() require('persistence').select() end,desc = 'Select session' },
    },
    -- lazy = false,
    init = function()
      vim.opt.sessionoptions = {
        -- 'blank',
        'buffers',
        'curdir',
        'folds',
        'globals',
        'help',
        -- 'localoptions',
        -- 'options',
        -- 'resize',
        -- 'sesdir',
        'skiprtp',
        'tabpages',
        'terminal',
        'winpos',
        'winsize',
      }
      vim.api.nvim_create_user_command('Restore', function()
        require('persistence').load()
      end, { desc = 'Restore session' })
      vim.api.nvim_create_user_command('RestoreLast', function()
        require('persistence').load({ last = true })
      end, { desc = 'Restore last session' })
      vim.api.nvim_create_user_command('Stop', function()
        require('persistence').stop()
        vim.g.current_session = nil
        -- vim.g.current_session_saved = nil
      end, { desc = 'Stop persistence' })

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

      -- vim.api.nvim_create_autocmd({
      --   'BufWritePost',
      --   'CursorMoved',
      --   -- 'TabClosed',
      --   -- 'TabNew',
      --   'TextChanged',
      --   -- 'TextChangedI',
      --   -- 'VimLeavePre',
      --   -- 'VimResized',
      --   -- 'WinScrolled',
      -- }, {
      --   callback = function()
      --     vim.g.current_session_saved = false
      --   end,
      -- })

      -- https://github.com/stevearc/overseer.nvim/discussions/373
      local function get_cwd_as_name()
        local dir = vim.fn.getcwd(0)
        return dir:gsub('[^A-Za-z0-9]', '_')
      end
      vim.api.nvim_create_autocmd('User', {
        desc = 'Save overseer.nvim tasks on persistence.nvim session save',
        pattern = 'PersistenceSavePre',
        callback = function()
          if not package.loaded.overseer then
            return
          end
          local overseer = require('overseer')
          overseer.save_task_bundle(get_cwd_as_name(), nil, { on_conflict = 'overwrite' })
        end,
      })
      vim.api.nvim_create_autocmd('User', {
        desc = 'Update current session',
        pattern = 'PersistenceSavePost',
        callback = function()
          -- vim.g.current_session = require('persistence').current()
          -- vim.g.current_session_saved = true
        end,
      })
      vim.api.nvim_create_autocmd('User', {
        desc = 'Remove all previous overseer.nvim tasks on persistence.nvim session load',
        pattern = 'PersistenceLoadPre',
        callback = function()
          if not package.loaded.overseer then
            return
          end
          local overseer = require('overseer')
          for _, task in ipairs(overseer.list_tasks({})) do
            task:dispose(true)
          end
        end,
      })
      vim.api.nvim_create_autocmd('User', {
        desc = 'Update current session and load overseer.nvim tasks on persistence.nvim session load',
        pattern = 'PersistenceLoadPost',
        callback = function()
          vim.g.current_session = require('persistence').current()
          -- vim.g.current_session_saved = false
          if not package.loaded.overseer then
            return
          end
          local overseer = require('overseer')
          overseer.load_task_bundle(get_cwd_as_name(), {
            autostart = false,
            ignore_missing = true,
          })
        end,
      })
    end,
  },
}
