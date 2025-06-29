if not vim.fn.has('nvim-0.8') then
  assert(false, 'nvim-0.8 required')
end

vim.g.mapleader = ' '

-- vim.o.background = 'dark'
vim.opt.clipboard:append({ 'unnamedplus' })
-- vim.opt.opt_global = true
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

-- https://github.com/folke/tokyonight.nvim
-- vim.cmd [[colorscheme tokyonight]]
vim.cmd.colorscheme('tokyonight-storm')

-- TODO: .config/vim/ftdetect?
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = { 'devcontainer.json', '.vscode/*.json' },
  callback = function()
    vim.bo.filetype = 'jsonc'
  end,
})
