if not vim.fn.has('nvim-0.8') then
  assert(false, 'nvim-0.8 required')
end

vim.g.mapleader = ' '
vim.g.localmapleader = ' '

-- vim.o.background = 'dark'

vim.opt.clipboard:append({ 'unnamedplus' })
-- TODO: Color colmn relative to textwidth

-- Reverse global flag (always apply to all, except if /g)
vim.opt.gdefault = true

-- Ignore case in search patterns
vim.opt.ignorecase = true

vim.opt.relativenumber = true

-- vim.opt.termguicolors = true

-- https://github.com/tpope/vim-sleuth
-- vim.opt.tabstop = 2
-- vim.opt.softtabstop = 2
-- vim.opt.shiftwidth = 2
-- vim.opt.expandtab = true
-- vim.opt.smartindent = true

-- Persistent undo history
-- https://github.com/vscode-neovim/vscode-neovim/issues/474
-- vim.opt.backup = true
-- vim.opt.backupdir = vim.fn.stdpath('config') .. '/backup//'
-- vim.opt.directory = vim.fn.stdpath('config') .. '/.swp//'
vim.opt.undofile = true
-- vim.opt.undodir = vim.fn.stdpath('config') .. '/undo//'

-- TODO: .config/vim/ftdetect?
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { 'devcontainer.json', '.vscode/*.json' },
  callback = function()
    vim.bo.filetype = 'jsonc'
  end,
})

-- https://github.com/folke/tokyonight.nvim
-- vim.cmd [[colorscheme tokyonight]]
local theme = 'catppuccin-macchiato'
-- local theme = 'rose-pine'
-- local theme = 'tokyonight-storm'
vim.cmd.colorscheme(theme)

local local_vimrc = vim.fn.expand('~/.vimrc.local')
if vim.fn.filereadable(local_vimrc) == 1 then
  vim.cmd('source ' .. local_vimrc)
end
