-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- vim.opt.autowrite = true

-- vim.o.background = 'dark'

-- Sync with system clipboard
-- vim.opt.clipboard:append({ 'unnamedplus' })
vim.opt.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'

vim.opt.completeopt = 'menu,menuone,noselect'

-- vim.opt.cmdheight = 2

-- Confirm to save changes before exiting modified buffer
vim.opt.confirm = true

vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}
-- Reverse global flag (always apply to all, except if /g)
vim.opt.gdefault = true

-- vim.opt.formatoptions = 'jcroqlnt' -- tcqj
-- vim.opt.grepformat = '%f:%l:%c:%m'
-- vim.opt.grepprg = 'rg --vimgrep'

-- Ignore case in search patterns
vim.opt.ignorecase = true

-- Preview incremental substitute
vim.opt.inccommand = 'nosplit'

if vim.fn.exists('&jumpoptions') then
  vim.opt.jumpoptions = 'view'
end

-- Always show the status line (3 = only the last windows)
vim.opt.laststatus = 2

-- Show invisible characters
vim.opt.list = true
vim.opt.listchars = {
  tab = '▸ ',
  trail = '·',
  extends = '❯', -- ›
  precedes = '❮', -- ‹
  nbsp = '_',
  eol = '¬',
}

-- Show the tab line (1 = only if at least 2 pages)
vim.opt.tabline = ' %t'
vim.opt.showtabline = 2
-- vim.api.nvim_create_autocmd('WinEnter', {
--   once = true,
--   pattern = '*',
--   callback = function()
--     vim.opt_local.showtabline = 2
--   end,
-- })

-- vim.opt.numberwidth = 4

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'

-- Popup blend
vim.opt.pumblend = 10
-- Maximum number of entries in a popup
vim.opt.pumheight = 10

-- Case sensitive when the search contains upper case characters
vim.opt.smartcase = true

-- FIXME: netrw auto download
vim.opt.spelllang = { 'en', 'fr' }

if vim.fn.exists('&splitkeep') then
  vim.opt.splitkeep = 'screen'
end

vim.opt.termguicolors = true

-- Lower than default (1000) to quickly trigger which-key
vim.opt.timeoutlen = vim.g.vscode and 1000 or 300

vim.opt.title = true

vim.opt.virtualedit = 'block'

-- Always show the window bar
-- vim.opt.winbar = ' %t'

-- Window
if vim.fn.has('windows') then
  vim.opt.splitbelow = true -- Split windows below the current window
  vim.opt.splitright = true -- Split windows right of the current window
  vim.opt.winminwidth = 5 -- Minimum window width
  vim.opt.winminheight = 0 -- Minimal height of node_version window when it's not the current one
  -- if vim.opt.tabpagemax < 50 then
  --   vim.opt.tabpagemax = 50 -- Maximum number of tab pages to be opened
  -- end
end

-- Disable line wrap
vim.opt.wrap = false
-- Wrap lines at convenient points
vim.opt.linebreak = true

-- Searches wrap around the end of the file
vim.opt.wrapscan = true

-- Cursor
vim.opt.cursorline = true -- Highlight the screen line of the cursor
vim.opt.startofline = false -- Keep the cursor on the same column when possible
vim.opt.scrolloff = 5 -- Lines to keep above and below the cursor
vim.opt.sidescroll = 1 -- Lines to scroll horizontally when 'wrap' is set
vim.opt.sidescrolloff = 5 -- Lines to the left and right if 'nowrap' is set

-- Indent
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
