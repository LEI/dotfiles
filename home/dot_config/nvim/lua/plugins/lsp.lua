-- {
--   'lukas-reineke/lsp-format.nvim',
--   opts = {
--     -- -- FIXME: use prettier to preserve new lines and update hx
--     -- json = { exclude = { 'jsonls' } },
--     -- json5 = { exclude = { 'jsonls' } },
--     -- jsonc = { exclude = { 'jsonls' } },
--
--     exclude = {
--       'intelephense', -- phpcs, phpcbf
--       'jsonls',       -- prettier
--     },
--     sync = true,
--
--     -- typescript = {
--     --   tab_width = function()
--     --     return vim.opt.shiftwidth:get()
--     --   end,
--     -- },
--     -- yaml = { tab_width = 2 },
--   },
--   init = function()
--     vim.api.nvim_create_autocmd('LspAttach', {
--       callback = function(args)
--         local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
--         require('lsp-format').on_attach(client, args.buf)
--       end,
--     })
--   end,
-- },

-- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#lazy-loading-with-lazynvim
return {
  {
    'neovim/nvim-lspconfig',
    tag = 'v2.3.0',
    lazy = true,
    config = function()
      -- Use global node for vscode-extracted-language-server
      local node_prefix = vim.g.config.node.prefix or ''
      local custom_settings = {
        cssls = {
          -- capabilities = vim.lsp.protocol.make_client_capabilities(),
          cmd = { node_prefix .. 'vscode-css-language-server', '--stdio' },
        },
        eslint = {
          cmd = { node_prefix .. 'vscode-eslint-language-server', '--stdio' },
        },
        html = {
          cmd = { node_prefix .. 'vscode-html-language-server', '--stdio' },
        },
        jsonls = {
          cmd = { node_prefix .. 'vscode-json-language-server', '--stdio' },
        },
      }

      local lspconfig = require('lspconfig')
      for name, settings in pairs(custom_settings) do
        local defaults = require('lspconfig.configs.' .. name)
        local server = lspconfig[name]
        server.setup(vim.tbl_deep_extend('keep', settings, defaults))
      end
    end,
  },
  {
    'adoyle-h/lsp-toggle.nvim',
    version = '1.1.1',
    dependencies = {
      'neovim/nvim-lspconfig',
      -- 'telescope.nvim',
    },
    cmd = { 'ToggleLSP', 'ToggleNullLSP' },
    opts = {
      create_cmds = true,
      telescope = false,
    },
  },
}
