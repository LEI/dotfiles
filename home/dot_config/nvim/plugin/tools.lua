-- https://github.com/mason-org/mason.nvim
require('mason').setup({
  registries = {
    "github:mason-org/mason-registry",
  },
})

require('mason-tool-installer').setup({
  ensure_installed = {
    'codespell',
    -- 'commitlint',
    -- 'gitlint',
    'hadolint',
    'markdownlint',
    'prettier',
    'shellcheck',
    'shfmt',
    'stylua',
    -- 'vale',
    'yamlfmt',
    'yamllint',

    -- Go
    'delve',
    'goimports',
    'golangci-lint',
  },
})

-- https://github.com/mason-org/mason-lspconfig.nvim
require('mason-lspconfig').setup({
  automatic_enable = true,
  -- TODO: exclude if already present, e.g. installed from source
  ensure_installed = {
    'angularls',
    'ansiblels',
    'docker_compose_language_service',
    'dockerls',
    'lua_ls',
    'nginx_language_server',
    'tailwindcss',
    'tofu_ls', -- 'terraformls',
    'vimls',

    -- TODO: DAP
    -- 'bash-debug-adapter',
    -- 'js-debug-adapter',

    -- Go
    'gopls',
    'golangci_lint_ls',

    -- Node
    'bashls',
    'cssls',
    'eslint',
    'html',
    'jsonls',
    'sqlls',
    'ts_ls',
    'yamlls',

    -- Rust
    'rust_analyzer',
    'taplo',
  },
})
