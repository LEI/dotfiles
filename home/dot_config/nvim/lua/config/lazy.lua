local function exec(command, desc, exit_code, silent)
  local out = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then
    local exit = exit_code == nil or exit_code ~= 0
    if not silent then
      vim.api.nvim_echo({
        { string.format('Failed to %s:\n', desc or 'execute command'), 'ErrorMsg' },
        { out, 'WarningMsg' },
        { exit and '' or '\nPress any key to exit...' },
      }, true, {})
    end
    if exit then
      return
    end
    -- vim.fn.getchar()
    -- os.exit(exit_code)
  end
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
local fs_stat = (vim.uv or vim.loop).fs_stat
if not fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local branch = 'stable'
  exec({ 'git', 'clone', '--filter=blob:none', '--branch=' .. branch, lazyrepo, lazypath }, 'clone lazy.nvim', 1)
end

local branch = 'feat/check-tags'
local remote = 'fork'
local remote_url = 'https://github.com/LEI/lazy.nvim.git'
-- exec({ 'git', '-C', lazypath, 'remote', 'remove', remote }, 'remove remote')
exec({ 'git', '-C', lazypath, 'remote', 'add', remote, remote_url }, 'add remote', 0, true)
exec({ 'git', '-C', lazypath, 'fetch', remote }, 'fetch remote')
exec({ 'git', '-C', lazypath, 'checkout', branch }, 'checkout branch')

vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' ' -- '_' -- '\\'

-- Setup lazy.nvim
require('lazy').setup({
  defaults = {
    -- Try installing the latest stable version for plugins that support semver
    version = '*',
  },
  spec = {
    -- { import = 'plugins' },

    -- { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },
    -- { import = 'lazyvim.plugins.extras.coding.copilot' },

    { import = 'plugins/ai' },
    { import = 'plugins/chezmoi' },
    { import = 'plugins/colorscheme' },
    { import = 'plugins/completion' },
    { import = 'plugins/dap' },
    { import = 'plugins/db' },
    { import = 'plugins/editor' },
    { import = 'plugins/extras' },
    { import = 'plugins/format' },
    { import = 'plugins/init' },
    { import = 'plugins/languages' },
    { import = 'plugins/lint' },
    { import = 'plugins/lsp' },
    { import = 'plugins/lualine' },
    { import = 'plugins/mason' },
    { import = 'plugins/oil' },
    { import = 'plugins/persistence' },
    { import = 'plugins/rest' },
    { import = 'plugins/snacks' },
    { import = 'plugins/test' },
    { import = 'plugins/tools' },
    { import = 'plugins/ui' },
    { import = 'plugins/undo' },
    { import = 'plugins/util' },
    { import = 'plugins/which-key' },
  },
  checker = {
    enabled = true,
    check_pinned = false,
    -- https://github.com/folke/lazy.nvim/issues/1729
    check_tags = true,
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
    missing = vim.g.config.lazy.install_missing or false,
  },
  ui = {
    backdrop = vim.g.config.backdrop or 60,
    border = vim.g.config.border or 'none',
    browser = 'firefox',
    icons = vim.g.config.signs.lazy_ui_icons or {},
    -- throttle = 1000 / 30, -- how frequently should the ui process render events
    -- custom_keys = {
    --   -- You can define custom key maps here. If present, the description will
    --   -- be shown in the help menu.
    --   -- To disable one of the defaults, set it to false.
    --
    --   ['<localleader>l'] = {
    --     function(plugin)
    --       require('lazy.util').float_term({ 'lazygit', 'log' }, {
    --         cwd = plugin.dir,
    --       })
    --     end,
    --     desc = 'Open lazygit log',
    --   },
    --
    --   ['<localleader>i'] = {
    --     function(plugin)
    --       Util.notify(vim.inspect(plugin), {
    --         title = 'Inspect ' .. plugin.name,
    --         lang = 'lua',
    --       })
    --     end,
    --     desc = 'Inspect Plugin',
    --   },
    --
    --   ['<localleader>t'] = {
    --     function(plugin)
    --       require('lazy.util').float_term(nil, {
    --         cwd = plugin.dir,
    --       })
    --     end,
    --     desc = 'Open terminal in plugin dir',
    --   },
    -- },
  },
  headless = {
    -- Show the output from process commands like git
    process = true,
    -- Show log messages
    log = true,
    -- Show task start/end
    task = true,
    -- Use ansi colors
    colors = true,
  },
})
