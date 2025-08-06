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
