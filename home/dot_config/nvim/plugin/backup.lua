-- Persistent undo history
-- TODO: /home/$GROUP (id -ng) to allow `newgrp`
local dir = vim.env.HOME .. '/.local/share/nvim'
local BACKUPDIR = dir .. '/backup//'
local SWAPDIR = dir .. '/swap//'
local UNDODIR = dir .. '/undo//'

if not vim.fn.isdirectory(BACKUPDIR) then
  vim.fn.mkdir(BACKUPDIR, 'p', '0o700')
end

vim.opt.backupdir = BACKUPDIR
vim.opt.directory = SWAPDIR
vim.opt.undodir = UNDODIR

vim.opt.backup = true
vim.opt.swapfile = false
vim.opt.undofile = true

-- au BufWritePre * let &bex = '-' .. strftime("%Y%b%d%X") .. '~'
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    local extension = '~' .. vim.fn.strftime('%Y-%m-%d-%H%M%S')
    vim.o.backupext = extension
  end,
})
