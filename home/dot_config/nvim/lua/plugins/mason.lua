return {
  {
    'mason-org/mason.nvim',
    tag = 'v2.0.0',
    cmd = {
      'Mason',
      'MasonInstall',
      'MasonLog',
      'MasonUninstall',
      'MasonUninstallAll',
    },
    -- event = 'VimEnter',
    keys = {
      { '<leader>M', '<cmd>Mason<cr>', desc = 'Mason' },
    },
    opts = {
      registries = {
        'github:mason-org/mason-registry',
      },
      ui = {
        -- icons = {
        --   package_installed = vim.g.config.signs.done,
        --   package_pending = vim.g.config.signs.pending,
        --   package_uninstalled = vim.g.config.signs.error,
        -- },
      },
    },
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    cmd = {
      'MasonToolsClean',
      'MasonToolsInstall',
      'MasonToolsInstallSync',
      'MasonToolsUpdate',
      'MasonToolsUpdateSync',
    },
    event = 'VeryLazy',
    opts = {
      ensure_installed = {
        -- Formatters
        'phpcbf',
        -- 'pgformatter',
        'prettier',
        'prettierd',
        'shfmt',
        -- 'sleek',
        'sql-formatter',
        -- 'sqlfluff',
        -- 'sqlfmt',
        'stylua',
        'yamlfmt',

        -- Linters
        -- 'actionlint',
        -- 'codespell',
        -- 'commitlint',
        -- 'cspell',
        -- 'gitleaks',
        -- 'gitlint',
        { 'hadolint', version = 'v2.12.0' },
        -- 'markdownlint',
        -- 'phpactor',
        'phpcs',
        'shellcheck',
        'sqlfluff',
        'yamllint',

        -- Go
        'goimports',
        'golangci-lint',
      },
      integrations = {
        ['mason-lspconfig'] = true,
        ['mason-null-ls'] = false,
        ['mason-nvim-dap'] = false,
      },
      run_on_start = false,
    },
    init = function()
      vim.api.nvim_create_autocmd('CursorHold', {
        callback = function()
          vim.cmd('MasonToolsInstall')
        end,
      })
    end,
  },

  {
    'mason-org/mason-lspconfig.nvim',
    tag = 'v2.0.0',
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
      'b0o/SchemaStore.nvim',
    },
    lazy = true,
    opts = {
      automatic_enable = true, -- { exclude = {} },
      -- automatic_enable = {
      --   'cssls',
      --   'eslint',
      --   'html',
      --   'jsonls',
      -- },
      -- TODO: exclude if already present, e.g. installed from source
      ensure_installed = {
        'angularls',
        'ansiblels',
        'docker_compose_language_service',
        'dockerls',
        'gh_actions_ls', -- gh-actions-language-server
        'gitlab_ci_ls',
        'helm_ls',
        'intelephense',
        'lua_ls',
        'marksman',
        'nginx_language_server',
        'postgres_lsp', -- postgrestools
        -- 'sqlls',
        'tailwindcss',
        'tofu_ls', -- 'terraformls',
        -- 'vale',
        'vimls',

        -- Go
        'golangci_lint_ls', -- golangci-lint-langserver
        'gopls',
        -- 'sqls',

        -- Node
        'bashls',

        -- TODO: use global vscode ls
        -- 'cssls',
        -- 'eslint',
        -- 'html',
        -- 'jsonls',

        'ts_ls',
        'yamlls',

        -- Rust
        'rust_analyzer',
        'taplo',
      },
    },
    init = function()
      -- TODO: folke/neoconf.nvim or tamago324/nlsp-settings.nvim
      local schemastore = require('schemastore')
      local lsp_settings = {
        intelephense = {
          settings = {
            files = { maxSize = 1000000 }, -- 1MB
            intelephense = {
              telemetry = {
                enabled = false,
              },
            },
          },
        },
        jsonls = {
          init_options = {
            provideFormatter = false,
          },
          settings = {
            json = {
              schemas = schemastore.json.schemas(),
              validate = { enable = true },
            },
          },
        },
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls
        lua_ls = {
          settings = {
            Lua = {
              -- diagnostics = {
              --   globals = { 'vim' },
              -- },
              runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                  'lua/?.lua',
                  'lua/?/init.lua',
                },
              },
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                },
              },
            },
          },
        },
        ts_ls = {
          on_attach = function(client, bufnr)
            -- TODO: only if eslint_ls is available in the buffer
            local has_eslint = false
            local get_lsp_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
            local clients = get_lsp_clients({ bufnr = bufnr })
            for _, c in ipairs(clients) do
              if c.name == 'eslint' then
                has_eslint = true
                break
              end
            end
            if has_eslint then
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
          end,
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = '',
              },
              schemas = schemastore.yaml.schemas(),
            },
          },
        },
      }

      for name, settings in pairs(lsp_settings) do
        vim.lsp.config(name, settings)
      end
    end,
  },
}
