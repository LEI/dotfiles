-- TODO: replace with mise when possible
local mason_packages_dir = vim.env.HOME .. '/.local/share/nvim/mason/packages'

-- local function has(feature, prog)
--   return function()
--     return vim.g.features[feature] and (vim.fn.executable(prog or feature) == 1)
--   end
-- end

local function has(...)
  local features = { ... }
  return function()
    for _, value in ipairs(features) do
      local name, prog
      if type(value) == 'table' then
        name = value[1]
        prog = value[2]
      else
        name = value
        prog = name
      end
      if vim.g.features[name] == false or (prog ~= nil and (vim.fn.executable(prog or name) == 0)) then
        return false
      end
    end
    return true
  end
end

-- TODO: do not install if already present, e.g. installed from source
local mason_tools = {
  -- Formatters
  { 'golangci-lint', condition = has('go') },
  { 'phpcbf', condition = has('php') },
  -- 'pgformatter',
  { 'prettier', condition = has('node') },
  { 'prettierd', condition = has('node') },
  'shfmt',
  -- 'sleek',
  { 'sql-formatter', condition = has({ 'sql', 'psql' }, 'node') },
  -- { 'sqlfmt', condition = has({ 'sql', 'psql' }) },
  'stylua',
  'yamlfmt',

  -- Linters
  -- 'actionlint',
  -- 'codespell',
  -- 'commitlint',
  -- 'cspell',
  -- 'gitleaks',
  -- 'gitlint',
  { 'goimports', condition = has('go') },
  'hadolint', -- { 'hadolint', version = 'v2.12.0' },
  { 'markdownlint', condition = has('node') },
  -- { 'phpactor', condition = has('php') },
  { 'phpcs', condition = has('php') },
  'shellcheck',
  { 'sqlfluff', condition = has({ 'sql', 'psql' }) },
  -- 'vale',
  'yamllint',

  -- Tools
  'gitui',
  { 'kulala-fmt', condition = has({ 'rest', nil }, 'node') },
}

local mason_lsp = {
  -- LSP
  { 'angularls', condition = has('node') }, -- 'angular-language-server',
  { 'ansiblels', condition = has('node') }, -- 'ansible-language-server',
  { 'cspell_ls', condition = has('node') }, -- 'cspell-lsp',
  { 'docker_compose_language_service', condition = has('docker') }, -- 'docker-compose-language-service',
  { 'dockerls', condition = has('docker') }, -- 'dockerfile-language-server',
  { 'gh_actions_ls', condition = has('node') }, -- 'gh-actions-language-server',
  { 'gitlab_ci_ls', condition = has('cargo') }, -- 'gitlab-ci-ls',
  { 'helm_ls', condition = has({ 'kube', 'kubectl' }, 'node') }, -- 'helm-ls',
  { 'intelephense', condition = has('php') },
  'lua_ls', -- 'lua-language-server',
  'marksman',
  {
    -- FIXME: install 0.9.0 only if python <3.14,>=3.9
    'nginx_language_server', -- 'nginx-language-server',
    condition = function()
      return vim.fn.executable('nginx') == 1
    end,
  },
  { 'postgres-language-server', condition = has({ 'sql', 'psql' }) }, -- 'postgres_lsp',
  -- 'sqlls',
  { 'tailwindcss', condition = has('node') }, -- 'tailwindcss-language-server',
  { 'tofu_ls', condition = has('tofu') }, -- 'tofu-ls', -- 'terraformls', -- 'terraformls-ls',
  -- 'vale_ls', -- 'vale-ls',
  { 'vimls', condition = has('node') }, -- 'vim-language-server',

  -- Go
  { 'golangci_lint_ls', condition = has('go') }, -- 'golangci-lint-langserver',
  { 'gopls', condition = has('go') },
  -- { 'sqls', condition = has('go') },

  -- Node
  { 'bashls', condition = has('bash', 'node') }, -- 'bash-language-server',

  -- TODO: use global vscode ls if installed
  { 'cssls', condition = has('node') }, -- 'css-lsp',
  { 'eslint', condition = has('node') }, -- 'eslint-lsp',
  { 'html', condition = has('node') }, -- 'html-lsp',
  { 'jsonls', condition = has('node') }, -- 'json-lsp',

  { 'ts_ls', condition = has('node') }, -- 'typescript-language-server',
  { 'yamlls', condition = has('node') }, -- 'yaml-language-server',

  -- Rust
  { 'rust_analyzer', condition = has('rust') }, -- 'rust-analyzer',
  'taplo',
}

local mason_dap = {
  { 'bash', enabled = vim.g.features.bash }, -- bash-debug-adapter
  -- 'chrome', -- chrome-debug-adapter
  -- 'codelldb', -- codelldb
  -- 'coreclr', -- netcoredbg
  'cppdbg', -- cpptools
  -- 'dart', -- dart-debug-adapter
  { 'delve', enabled = vim.g.features.go }, -- delve
  -- 'elixir', -- elixir-ls
  -- 'erlang', -- erlang-debugger
  'firefox', -- firefox-debug-adapter
  -- 'haskell', -- haskell-debug-adapter
  -- 'javadbg', -- java-debug-adapter
  -- 'javatest', -- java-test
  { 'js', enabled = vim.g.features.node }, -- js-debug-adapter
  -- 'kotlin', -- kotlin-debug-adapter
  -- 'mock', -- mockdebug
  -- 'node2', -- node-debug2-adapter
  { 'php', condition = has('php') }, -- php-debug-adapter
  -- 'puppet', -- puppet-editor-services
  { 'python', enabled = vim.g.features.python }, -- debugpy
}

for _, name in pairs(mason_lsp) do
  table.insert(mason_tools, name)
end

if vim.g.ai and vim.g.ai.sidekick and (vim.fn.executable('npm') == 1) then
  table.insert(mason_tools, 'copilot-language-server')
end

local node_prefix = vim.g.config.node.prefix or ''

return {
  {
    'mason-org/mason.nvim',
    -- tag = 'v2.0.1',
    version = 'v2.x',
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
        ---@since 1.0.0
        -- Whether to automatically check for new versions when opening the :Mason window.
        check_outdated_packages_on_open = true,

        ---@since 1.0.0
        -- The border to use for the UI window. Accepts same border values as |nvim_open_win()|.
        -- Defaults to `:h 'winborder'` if nil.
        border = vim.g.config.border or nil,

        ---@since 1.11.0
        -- The backdrop opacity. 0 is fully opaque, 100 is fully transparent.
        backdrop = vim.g.config.backdrop or 60,

        ---@since 1.0.0
        -- Width of the window. Accepts:
        -- - Integer greater than 1 for fixed width.
        -- - Float in the range of 0-1 for a percentage of screen width.
        width = 0.8,

        ---@since 1.0.0
        -- Height of the window. Accepts:
        -- - Integer greater than 1 for fixed height.
        -- - Float in the range of 0-1 for a percentage of screen height.
        height = 0.8, -- 0.9,

        icons = {
          --   package_installed = vim.g.config.signs.done,
          --   package_pending = vim.g.config.signs.pending,
          --   package_uninstalled = vim.g.config.signs.error,

          ---@since 1.0.0
          -- The list icon to use for installed packages.
          package_installed = '◍',
          ---@since 1.0.0
          -- The list icon to use for packages that are installing, or queued for installation.
          package_pending = '◍',
          ---@since 1.0.0
          -- The list icon to use for packages that are not installed.
          package_uninstalled = '◍',
        },

        keymaps = {
          ---@since 1.0.0
          -- Keymap to expand a package
          toggle_package_expand = '<CR>',
          ---@since 1.0.0
          -- Keymap to install the package under the current cursor position
          install_package = 'i',
          ---@since 1.0.0
          -- Keymap to reinstall/update the package under the current cursor position
          update_package = 'u',
          ---@since 1.0.0
          -- Keymap to check for new version for the package under the current cursor position
          check_package_version = 'c',
          ---@since 1.0.0
          -- Keymap to update all installed packages
          update_all_packages = 'U',
          ---@since 1.0.0
          -- Keymap to check which installed packages are outdated
          check_outdated_packages = 'C',
          ---@since 1.0.0
          -- Keymap to uninstall a package
          uninstall_package = 'X',
          ---@since 1.0.0
          -- Keymap to cancel a package installation
          cancel_installation = '<C-c>',
          ---@since 1.0.0
          -- Keymap to apply language filter
          apply_language_filter = '<C-f>',
          ---@since 1.1.0
          -- Keymap to toggle viewing package installation log
          toggle_package_install_log = '<CR>',
          ---@since 1.8.0
          -- Keymap to toggle the help view
          toggle_help = 'g?',
        },
      },
    },
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'mason-org/mason.nvim',

      -- 'mason-org/mason-lspconfig.nvim',
      -- 'neovim/nvim-lspconfig',
    },
    cmd = {
      'MasonToolsClean',
      'MasonToolsInstall',
      'MasonToolsInstallSync',
      'MasonToolsUpdate',
      'MasonToolsUpdateSync',
    },
    lazy = not vim.g.config.mason.run_on_start, -- event = 'VeryLazy',
    opts = {
      ensure_installed = mason_tools,
      integrations = {
        ['mason-lspconfig'] = true,
        ['mason-null-ls'] = false,
        ['mason-nvim-dap'] = false,
      },
      run_on_start = vim.g.config.mason.run_on_start,
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
    -- branch = 'main',
    -- tag = 'v2.1.0',
    version = 'v2.x',
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
      'b0o/SchemaStore.nvim',
      'saghen/blink.cmp',
      -- 'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    -- cmd = {
    --   -- 'LspEslintFixAll',
    --   'LspInfo',
    --   'LspInstall',
    --   'LspLog',
    --   -- 'LspRestart',
    --   'LspStart',
    --   -- 'LspStop',
    --   'LspUninstall',
    -- },
    event = 'VeryLazy',
    opts = {
      automatic_enable = {
        exclude = {
          -- Already included as a formatter
          'stylua',
        },
      },
      -- ensure_installed = {},
    },
    init = function()
      -- https://www.lazyvim.org/plugins/lsp
      -- https://www.lazyvim.org/configuration/keymaps#lsp-keymaps

      -- FIXME: lua =vim.lsp.get_clients()[1].server_capabilities.workspace
      -- local lspconfig = require('lspconfig')
      -- local has_blink, blink = pcall(require, 'blink.cmp')
      -- local capabilities = vim.tbl_deep_extend(
      --   'force',
      --   {},
      --   -- lspconfig.util.default_config.capabilities,
      --   has_blink and blink.get_lsp_capabilities() or {},
      --   {
      --     workspace = {
      --       fileOperations = {
      --         didRename = true,
      --         willRename = true,
      --       },
      --     },
      --   }
      -- )
      -- vim.lsp.config('*', { capabilities = capabilities })

      -- TODO: folke/neoconf.nvim or tamago324/nlsp-settings.nvim
      if vim.lsp.config then
        local schemastore = require('schemastore')
        local lsp_settings = {
          copilot = {
            cmd = {
              node_prefix .. 'node',
              vim.env.HOME
                .. '/.local/share/nvim/mason/packages/copilot-language-server/node_modules/@github/copilot-language-server/dist/language-server.js',
              '--stdio',
            },
            filetypes = vim.g.config.filetypes,
            settings = {
              telemetry = {
                telemetryLevel = 'off',
              },
            },
          },
          cspell_ls = {
            cmd = {
              'cspell-lsp',
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
          tailwindcss = {
            -- filetypes = {
            --   'css',
            --   'less',
            --   'postcss',
            --   'sass',
            --   'scss',
            --   'stylus',
            --   'sugarss',
            -- },
            filetypes = require('config.functions').removeValues(
              require('lspconfig.configs.tailwindcss').default_config.filetypes,
              { 'javascript', 'typescript', 'php' }
            ),
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
                kubernetesCRDStore = {
                  enable = true,
                },
              },
            },
          },
        }

        for name, settings in pairs(lsp_settings) do
          vim.lsp.config(name, settings)
        end
      end

      -- https://neovim.io/doc/user/lsp.html#lsp-attach
      -- vim.api.nvim_create_autocmd('LspAttach', {
      --   group = vim.api.nvim_create_augroup('my.lsp', {}),
      --   callback = function(args)
      --     local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      --     if client:supports_method('textDocument/implementation') then
      --       -- Create a keymap for vim.lsp.buf.implementation ...
      --     end
      --     -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
      --     if client:supports_method('textDocument/completion') then
      --       -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      --       -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      --       -- client.server_capabilities.completionProvider.triggerCharacters = chars
      --       vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      --     end
      --     -- Auto-format ("lint") on save.
      --     -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
      --     if
      --       not client:supports_method('textDocument/willSaveWaitUntil')
      --       and client:supports_method('textDocument/formatting')
      --     then
      --       vim.api.nvim_create_autocmd('BufWritePre', {
      --         group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
      --         buffer = args.buf,
      --         callback = function()
      --           vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
      --         end,
      --       })
      --     end
      --   end,
      -- })
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
    -- tag = 'v2.5.1',
    version = 'v2.x',
    dependencies = {
      'mason-org/mason.nvim',
    },
    cmd = {
      'DapInstall',
      'DapUninstall',
    },
    opts = {
      -- https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/source.lua
      ensure_installed = mason_dap,
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
