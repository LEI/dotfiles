return {
  {
    -- highlighting for chezmoi files template files
    'alker0/chezmoi.vim',
    -- event = 'BufEnter',
    lazy = false,
    init = function()
      vim.g['chezmoi#use_tmp_buffer'] = true
      -- vim.g['chezmoi#source_dir_path'] = vim.env.HOME .. '/.local/share/chezmoi'
    end,
  },
  {
    'xvzc/chezmoi.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
    },
    cmd = { 'ChezmoiEdit', 'ChezmoiList' },
    keys = {
      -- { '<leader>sC', chezmoi_picker, desc = 'Search dotfiles (chezmoi)' },
      {
        '<leader>sC',
        function()
          require('chezmoi.pick').snacks(vim.fn.stdpath('config'), {
            '--path-style=absolute',
            '--include=files',
            '--exclude=externals',
          })
        end,
        desc = 'Search dotfiles (chezmoi)',
      },
    },
    opts = {
      edit = {
        watch = false,
        force = false,
        -- ignore_patterns = {
        --   'run_onchange_.*',
        --   'run_once_.*',
        --   '%.chezmoiignore',
        --   '%.chezmoitemplate',
        --   -- Add custom patterns here
        -- },
      },
      events = {
        on_open = {
          notification = {
            enable = true,
            msg = 'Opened a chezmoi-managed file',
            opts = {},
          },
        },
        on_watch = {
          notification = {
            enable = true,
            msg = 'This file will be automatically applied',
            opts = {},
          },
        },
        on_apply = {
          notification = {
            enable = true,
            msg = 'Successfully applied',
            opts = {},
          },
        },
      },
    },
    init = function()
      -- local prefix = 'Chezmoi'
      -- local toggle_option = 'disable_chezmoi_watch'
      -- local desc = 'chezmoi watch'
      -- vim.api.nvim_create_user_command(prefix .. 'Disable', function(args)
      --   if args.bang then
      --     vim.b[toggle_option] = true
      --   else
      --     vim.g[toggle_option] = true
      --   end
      -- end, { desc = 'Disable ' .. desc, bang = true })
      -- vim.api.nvim_create_user_command(prefix .. 'Enable', function(args)
      --   if args.bang then
      --     vim.b[toggle_option] = false
      --   else
      --     vim.g[toggle_option] = false
      --   end
      -- end, { desc = 'Enable ' .. desc, bang = true })
      -- vim.api.nvim_create_user_command(prefix .. 'Toggle', function(args)
      --   if args.bang then
      --     vim.b[toggle_option] = not vim.b[toggle_option]
      --   else
      --     vim.g[toggle_option] = not vim.g[toggle_option]
      --   end
      -- end, { desc = 'Toggle ' .. desc, bang = true })

      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = { vim.env.HOME .. '/.local/share/chezmoi/*' },
        callback = function(ev)
          local bufnr = ev.buf
          if
            bufnr == nil
            or vim.bo[bufnr].filetype == 'gitcommit'
            or vim.bo[bufnr].filetype == 'gitrebase'
            or vim.bo[bufnr].filetype == 'diff'
          then
            return
          end
          -- if vim.g.disable_chezmoi_watch or vim.b[bufnr].disable_chezmoi_watch then
          --   return
          -- end
          local cwd = vim.fn.getcwd()
          local file = vim.api.nvim_buf_get_name(bufnr)
          -- TODO: use ignore_patterns
          local ignore_prefix = '^%.'
          local name = vim.fn.fnamemodify(file, ':t')
          if name:match(ignore_prefix) then
            return
          end
          local relative = file:gsub('^' .. cwd .. '/', '')
          if relative:match(ignore_prefix) then
            return
          end
          local edit_watch = function()
            local chezmoiroot = cwd .. '/.chezmoiroot'
            local root = vim.fn.filereadable(chezmoiroot) == 1 and vim.fn.readfile(chezmoiroot)[1] or nil
            if
              root ~= nil
              and ((not vim.startswith(relative, root)) or relative:gsub('^' .. root .. '/', ''):match(ignore_prefix))
            then
              return
            end
            require('chezmoi.commands.__edit').watch(bufnr)
          end
          vim.schedule(edit_watch)
        end,
      })
    end,
  },
}
