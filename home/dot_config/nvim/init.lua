if not vim.fn.has('nvim-0.8') then
  assert(false, 'nvim-0.8 required')
end

require('config.init')
require('config.options')
require('config.autocmds')
require('config.lazy')
require('config.keymaps')

vim.cmd.colorscheme(vim.g.config.colorscheme)

local local_vimrc = vim.fn.expand('~/.vimrc.local')
if vim.fn.filereadable(local_vimrc) == 1 then
  vim.cmd('source ' .. local_vimrc)
end

local local_vimrc_lua = vim.fn.expand('~/.config/nvim/init.lua.local')
if vim.fn.filereadable(local_vimrc_lua) == 1 then
  vim.cmd('luafile ' .. local_vimrc_lua)
end
