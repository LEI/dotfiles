-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/formatting/prettier.lua
-- https://github.com/stevearc/dotfiles/blob/master/.config/nvim/lua/plugins/format.lua

local prettier = {
  -- 'prettierd',
  'prettier',
  -- stop_after_first = true,
}

return {
  {
    -- Alternative: nvimtools/none-ls.nvim + lukas-reineke/lsp-format.nvim
    'stevearc/conform.nvim',
    tag = 'v9.0.0',
    dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    cmd = {
      'ConformInfo',
      'Format',
      'FormatInfo',
      'FormatDisable',
      'FormatEnable',
    },
    event = {
      'BufWritePre',
      -- 'CursorHold',
      'VeryLazy',
    },
    keys = {
      {
        'gqq', -- '<leader>F', -- cf
        '<cmd>Format<cr>',
        desc = 'Format buffer',
        mode = '',
      },
    },
    -- This will provide type hinting with LuaLS
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      default_format_opts = {
        -- async = false,
        lsp_format = 'fallback',
        -- timeout_ms = 500,
        -- Conform writes a temporary file if stdin is false
        tmpfile_format = '.conform.$RANDOM.$FILENAME~',
      },
      -- NOTE: format_on_save cannot be async, use format_after_save instead
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- FIXME: this overrides timeout set per formatter
        -- return { timeout_ms = 5000 }
        return { timeout_ms = 15000 }
        -- local name = ''
        -- local options = {}
        -- if vim.bo.filetype ~= '' and opts.formatters_by_ft[vim.bo.filetype] ~= nil then
        --   local formatter_for_ft = opts.formatters_by_ft[vim.bo.filetype]
        --   name = formatter_for_ft[1] or ''
        --   if name ~= '' then
        --     options = opts.formatters[name] or {}
        --   end
        -- end
        -- -- vim.notify('Formatting' .. (name and (' with ' .. name) or '') .. '...', vim.log.levels.TRACE, { title = 'conform.nvim' })
        -- -- local extend = require('conform').get_formatter_config(name)
        -- return vim.tbl_deep_extend('keep', options or {})
      end,
      -- https://github.com/stevearc/conform.nvim/tree/master/lua/conform/formatters
      formatters = {
        -- shfmt = { prepend_args = { '-i', '2' } },
        phpcbf = {
          timeout_ms = 15000,
          -- WARN: phpcbf ignores hidden files
          -- tmpfile_format = 'conform.$RANDOM.$FILENAME~',
        },
        -- sqlfluff = {
        --   -- command = vim.g.home .. '/.local/share/nvim/mason/bin/sqlfluff',
        --   append_args = { '--dialect', 'postgres' }, -- mariadb, mysql, sqlite...
        --   require_cwd = false,
        -- },
      },
      formatters_by_ft = {
        css = prettier,
        html = prettier,
        json = prettier,
        json5 = prettier,
        jsonc = prettier,
        lua = { 'stylua' },
        -- python = { 'isort', 'black' },
        -- WARN: intelphense causes indentation conflicts
        php = { 'phpcbf', lsp_format = 'never' },

        sql = {
          -- 'sleek',
          'sql_formatter',
          -- 'sqlfluff',
          -- 'sqlfmt',
        },
        mysql = {
          'sql_formatter',
        },
        plsql = {
          -- 'pg_format',
          'sql_formatter',
        },
      },
      log_level = vim.log.levels.TRACE,
      notify_no_formatters = true,
      notify_on_error = true,
    },
    config = function(_, opts)
      local conform = require('conform')
      -- Extend default formatter options
      for name, extra in pairs(opts.formatters) do
        local defaults = conform.get_formatter_config(name)
        local extended = vim.tbl_deep_extend('keep', extra, defaults)
        opts.formatters[name] = extended
      end
      conform.setup(opts)

      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      -- Format command
      vim.api.nvim_create_user_command('Format', function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ['end'] = { args.line2, end_line:len() },
          }
        end
        local options = {
          async = not args.bang,
          range = range,
        }
        require('conform').format(options)
      end, { bang = true, range = true })

      -- Toggle format on save
      vim.api.nvim_create_user_command('FormatDisable', function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = 'Disable autoformat-on-save',
        bang = true,
      })
      vim.api.nvim_create_user_command('FormatEnable', function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = 'Re-enable autoformat-on-save',
      })
      -- local conform = require('conform')
      vim.api.nvim_create_user_command('FormatInfo', function()
        vim.cmd('ConformInfo')
        -- local all = conform.list_all_formatters() or {}
        -- local fmt = {}
        -- for _, item in pairs(all) do
        --   table.insert(
        --     fmt,
        --     (item.available == true and vim.g.config.signs.done or vim.g.config.signs.error)
        --       .. ' '
        --       .. item.name
        --       .. (item.name ~= item.command and (' (' .. item.command .. ')') or '')
        --   )
        -- end
        -- vim.notify('Formatters:\n' .. table.concat(fmt, '\n'), vim.log.levels.INFO, { title = 'conform.nvim' })
      end, {
        desc = 'Format info (Conform)',
      })
    end,
  },
}
