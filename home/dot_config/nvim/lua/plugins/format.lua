-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
-- https://github.com/stevearc/dotfiles/blob/master/.config/nvim/lua/plugins/format.lua

local prettier = {
  -- 'prettierd',
  'prettier',
  lsp_format = 'prefer',
  -- stop_after_first = true,
}

-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/formatting/prettier.lua
local prettier_filetypes = {
  'css',
  'graphql',
  'handlebars',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'less',
  -- 'markdown',
  'markdown.mdx',
  'scss',
  'typescript',
  'typescriptreact',
  'vue',
  'yaml',
}

return {
  {
    -- Alternative: nvimtools/none-ls.nvim + lukas-reineke/lsp-format.nvim
    'stevearc/conform.nvim',
    enabled = vim.fn.has('nvim-0.10') == 1,
    tag = 'v9.1.0',
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
        injected = {
          options = {
            -- Set to true to ignore errors
            ignore_errors = false,
            -- Map of treesitter language to filetype
            lang_to_ft = {
              -- bash = 'sh',
            },
            -- Map of treesitter language to file extension
            -- A temporary file name with this extension will be generated during formatting
            -- because some formatters care about the filename.
            lang_to_ext = {
              -- bash = 'sh',
              -- c_sharp = 'cs',
              -- elixir = 'exs',
              -- javascript = 'js',
              -- julia = 'jl',
              -- latex = 'tex',
              -- markdown = 'md',
              -- python = 'py',
              -- ruby = 'rb',
              -- rust = 'rs',
              -- teal = 'tl',
              -- typescript = 'ts',
            },
            -- Map of treesitter language to formatters to use
            -- (defaults to the value from formatters_by_ft)
            lang_to_formatters = {
              bash = { 'shfmt' },
              sh = { 'shfmt' },
            },
          },
        },
        -- shfmt = { prepend_args = { '-i', '2' } },
        phpcbf = {
          timeout_ms = 15000,
          -- WARN: phpcbf ignores hidden files
          -- tmpfile_format = 'conform.$RANDOM.$FILENAME~',
        },
        -- sqlfluff = {
        --   -- command = vim.env.HOME .. '/.local/share/nvim/mason/bin/sqlfluff',
        --   append_args = { '--dialect', 'postgres' }, -- mariadb, mysql, sqlite...
        --   require_cwd = false,
        -- },
      },
      formatters_by_ft = {
        json5 = prettier,
        markdown = {
          'prettier',
          'injected',
          lsp_format = 'fallback', -- 'first',
        },
        toml = {
          -- 'prettier',
          'injected',
          lsp_format = 'first',
        },

        -- Disable LSP formatting
        lua = { 'stylua' },

        -- python = { 'isort', 'black' },

        -- WARN: intelphense causes indentation conflicts
        php = { 'phpcbf', lsp_format = 'never', enabled = vim.g.features.php },

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
      -- log_level = vim.log.levels.TRACE,
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
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(prettier_filetypes) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], 'prettier')
        opts.formatters_by_ft[ft].lsp_format = prettier.lsp_format
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

      -- FormatDisable! will disable formatting just for this buffer
      local prefix = 'Format'
      local toggle_option = 'disable_autoformat'
      local desc = 'autoformat on save'
      vim.api.nvim_create_user_command(prefix .. 'Disable', function(args)
        if args.bang then
          vim.b[toggle_option] = true
        else
          vim.g[toggle_option] = true
        end
      end, { desc = 'Disable ' .. desc, bang = true })
      vim.api.nvim_create_user_command(prefix .. 'Enable', function(args)
        if args.bang then
          vim.b[toggle_option] = false
        else
          vim.g[toggle_option] = false
        end
      end, { desc = 'Enable ' .. desc, bang = true })
      vim.api.nvim_create_user_command(prefix .. 'Toggle', function(args)
        if args.bang then
          vim.b[toggle_option] = not vim.b[toggle_option]
        else
          vim.g[toggle_option] = not vim.g[toggle_option]
        end
      end, { desc = 'Toggle ' .. desc, bang = true })

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
