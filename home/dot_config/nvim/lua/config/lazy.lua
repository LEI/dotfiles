-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = '_' -- '\\'

-- Setup lazy.nvim
require('lazy').setup({
  defaults = {
    -- Try installing the latest stable version for plugins that support semver
    version = '*',
  },
  spec = {
    { import = 'plugins' },
    -- { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    -- { import = 'lazyvim.plugins.extras.coding.copilot' },
  },
  checker = {
    enabled = true,
    -- https://github.com/folke/lazy.nvim/issues/1729
    check_pinned = false,
    -- check_tags = true,
  },
  change_detection = {
    -- Automatically check for config file changes and reload the ui
    enabled = true,
    -- Get a notification when changes are found
    notify = true,
  },
  dev = {
    -- path = '~/projects',
    path = function(plugin)
      local path = plugin.url:gsub('^https://', ''):gsub('.git$', '')
      return '~/src/' .. path
    end,
    patterns = {},
    fallback = false,
  },
  install = {
    colorscheme = { vim.g.config.theme.colorscheme },
    missing = true,
  },
  ui = {
    browser = 'firefox',
  },
  -- headless = {
  --   -- show the output from process commands like git
  --   process = true,
  --   -- show log messages
  --   log = true,
  --   -- show task start/end
  --   task = true,
  --   -- use ansi colors
  --   colors = true,
  -- },
})

-- https://github.com/folke/lazy.nvim/discussions/1188
-- https://github.com/LazyVim/LazyVim/discussions/3679
local get_action = function(action)
  return function(args)
    -- To detect if a UI is available, check if nvim_list_uis() is
    -- empty during or after VimEnter.
    -- vim.autocmd('VimEnter')
    -- local headless = #vim.api.nvim_list_uis() == 0

    vim.print(action .. ' packages...')
    vim.cmd('Lazy' .. (args.bang and '!' or '') .. ' ' .. string.lower(action))

    vim.print(action .. ' parsers...')
    vim.cmd('TSUpdate' .. (args.bang and 'Sync' or ''))

    -- FIXME: vim.lsp.config may be nil when headless
    -- https://github.com/mason-org/mason-lspconfig.nvim/blob/v2.0.0/lua/mason-lspconfig/mappings.lua#L28

    -- automatic_enable.lua:47: attempt to call field 'enable' (a nil value)
    -- https://github.com/mason-org/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/features/automatic_enable.lua#L47

    vim.print(action .. ' tools...')
    vim.cmd('MasonTools' .. action .. (args.bang and 'Sync' or ''))
  end
end
vim.api.nvim_create_user_command('LazyInstall', get_action('Install'), { desc = 'Install', bang = true })
vim.api.nvim_create_user_command('LazyUpdate', get_action('Update'), { desc = 'Update', bang = true })
