local mason_packages_dir = vim.g.home .. '/.local/share/nvim/mason/packages'

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
        'golangci-lint',
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
        'goimports',
        { 'hadolint', version = 'v2.12.0' },
        -- 'markdownlint',
        -- 'phpactor',
        'phpcs',
        'shellcheck',
        'sqlfluff',
        'yamllint',

        -- Tools
        'gitui',
        'kulala-fmt',
      },
      integrations = {
        ['mason-lspconfig'] = false,
        ['mason-null-ls'] = false,
        ['mason-nvim-dap'] = false,
      },
      run_on_start = false,
    },
    init = function()
      -- vim.api.nvim_create_autocmd('CursorHold', {
      --   callback = function()
      --     vim.cmd('MasonToolsInstall')
      --   end,
      -- })
    end,
  },

  -- LSP
  {
    'mason-org/mason-lspconfig.nvim',
    tag = 'v2.0.0',
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
      'b0o/SchemaStore.nvim',
    },
    event = 'VeryLazy',
    -- lazy = true,
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
        'cspell_ls',
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

        -- TODO: use global vscode ls (install-tools-node.sh)
        'cssls',
        'eslint',
        'html',
        'jsonls',

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
        cspell_ls = {
          cmd = {
            'cspell-lsp',
            -- TODO: allow override per project
            '--config=~/.config/cspell/cspell.json',
            '--stdio',
          },
          filetypes = {
            -- 'css',
            -- 'gitcommit',
            -- 'go',
            -- 'html',
            -- 'js',
            -- 'json',
            -- 'lua',
            'markdown',
            'plaintext',
            -- 'rust',
            -- 'ts',
            -- 'yaml',
          },
        },
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
        tofu_ls = {
          filetypes = { 'opentofu', 'opentofu-vars', 'terraform', 'terraform-vars' },
        },
        -- TODO: https://www.lazyvim.org/extras/lang/typescript
        ts_ls = {
          on_attach = function(client, bufnr)
            local function on_attach()
              local clients = vim.lsp.get_clients({ bufnr = bufnr })
              local eslint_is_attached = false
              for _, c in pairs(clients) do
                if c.name == 'eslint' then
                  eslint_is_attached = true
                  break
                end
              end
              client.server_capabilities.documentFormattingProvider = not eslint_is_attached
              client.server_capabilities.documentRangeFormattingProvider = not eslint_is_attached
            end
            vim.api.nvim_create_autocmd('LspAttach', {
              buffer = bufnr,
              callback = on_attach,
            })
          end,
        },
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
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
  --[[
  -- https://github.com/LazyVim/LazyVim/discussions/1621
  {
    'someone-stole-my-name/yaml-companion.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
      -- 'nvim-telescope/telescope.nvim',
    },
    ft = 'yaml',
    keys = {
      {
        '<leader>sY',
        function()
          local schema = require('yaml-companion').get_buf_schema(0)
          -- if schema.result[1].name == 'none' then
          --   return ''
          -- end
          vim.print(schema.result[1].name)
        end,
        desc = 'Get YAML Schema',
      },
      {
        '<leader>sy',
        function()
          require('yaml-companion').open_ui_select()
        end,
        desc = 'Select YAML Schema',
      },
    },
    opts = {
      builtin_matchers = {
        kubernetes = { enabled = true },
      },
    },
    config = function(_, opts)
      local cfg = require('yaml-companion').setup(opts)
      require('lspconfig').yamlls.setup(cfg)
      -- require('telescope').load_extension('yaml_schema')
    end,
  },
  --]]

  -- DAP
  {
    'jay-babu/mason-nvim-dap.nvim',
    tag = 'v2.5.1',
    dependencies = {
      'mason-org/mason.nvim',
    },
    cmd = {
      'DapInstall',
      'DapUninstall',
    },
    opts = {
      -- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
      ensure_installed = {
        'bash', -- bash-debug-adapter
        -- 'chrome', -- chrome-debug-adapter
        -- 'codelldb', -- codelldb
        -- 'coreclr', -- netcoredbg
        'cppdbg', -- cpptools
        -- 'dart', -- dart-debug-adapter
        'delve', -- delve
        -- 'elixir', -- elixir-ls
        -- 'erlang', -- erlang-debugger
        'firefox', -- firefox-debug-adapter
        -- 'haskell', -- haskell-debug-adapter
        -- 'javadbg', -- java-debug-adapter
        -- 'javatest', -- java-test
        'js', -- js-debug-adapter
        -- 'kotlin', -- kotlin-debug-adapter
        -- 'mock', -- mockdebug
        -- 'node2', -- node-debug2-adapter
        'php', -- php-debug-adapter
        -- 'puppet', -- puppet-editor-services
        'python', -- debugpy
      },
      automatic_installation = true,
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require('mason-nvim-dap').default_setup(config)
        end,
        js = function(config)
          -- https://github.com/microsoft/vscode-js-debug/blob/main/OPTIONS.md
          -- https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
          -- https://code.visualstudio.com/docs/nodejs/nodejs-debugging#_launch-configuration-attributes
          config.adapters = {
            -- type = 'executable',
            -- command = vim.fn.exepath('js-debug-adapter'),
            type = 'server',
            host = 'localhost',
            port = '${port}',
            executable = {
              command = 'node',
              args = { mason_packages_dir .. '/js-debug-adapter/js-debug/src/dapDebugServer.js', '${port}' },
            },
          }
          require('mason-nvim-dap').default_setup(config)
        end,
      },
    },
    config = function(_, opts)
      local dap = require('dap')
      require('mason-nvim-dap').setup(opts)
      -- dap.adapters.js,
      local js = {
        {
          type = 'js',
          request = 'launch',
          name = 'JS: Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
      }
      table.insert(dap.configurations.javascript, js)
      table.insert(dap.configurations.javascriptreact, js)
      table.insert(dap.configurations.typescript, js)
      table.insert(dap.configurations.typescriptreact, js)
      -- vim.print('Adapters', dap.adapters, 'Configs', dap.configurations)
    end,
  },
}
