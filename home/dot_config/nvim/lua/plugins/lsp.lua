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
    -- tag = 'v2.4.0',
    version = 'v2.x',
    lazy = true,
    init = function()
      -- local lspconfig = require('lspconfig')
      -- -- TODO: use global node for vscode-langservers-extracted
      -- local node_prefix = vim.g.config.node.prefix or ''
      -- local custom_settings = {
      --   cssls = {
      --     -- capabilities = vim.lsp.protocol.make_client_capabilities(),
      --     -- cmd = { 'vscode-css-language-server', '--stdio' },
      --   },
      --   eslint = {
      --     cmd = { node_prefix .. 'vscode-eslint-language-server', '--stdio' },
      --   },
      --   html = {
      --     -- cmd = { 'vscode-html-language-server', '--stdio' },
      --   },
      --   jsonls = {
      --     -- cmd = { 'vscode-json-language-server', '--stdio' },
      --   },
      -- }
      --
      -- for name, settings in pairs(custom_settings) do
      --   local defaults = require('lspconfig.configs.' .. name)
      --   local server = lspconfig[name]
      --   server.setup(vim.tbl_deep_extend('keep', settings, defaults))
      -- end
    end,
  },
  {
    'adoyle-h/lsp-toggle.nvim',
    version = '1.1.1',
    dependencies = {
      'neovim/nvim-lspconfig',
      -- 'telescope.nvim',
    },
    -- cmd = 'ToggleLSP',
    keys = {
      { '<leader>lt', '<cmd>ToggleLSP<cr>', desc = 'Toggle LSP' },
    },
    opts = {
      create_cmds = false,
      telescope = false,
    },
    init = function()
      local name = 'ToggleLSP'
      vim.api.nvim_create_user_command(name, function()
        local ext = require('lsp-toggle.lsp')
        local items = ext.command()
        vim.ui.select(items, {
          prompt = name,
          format_item = function(item)
            return item.text
          end,
        }, function(selection)
          if selection then
            ext.onSubmit(selection)
          end
        end)
      end, { desc = 'Disable/Enable LSP for current buffer' })
    end,
  },
}
