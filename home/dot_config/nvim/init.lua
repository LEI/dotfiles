if not vim.fn.has('nvim-0.8') then
  assert(false, 'nvim-0.8 required')
end

-- vim.o.background = 'dark'

vim.opt.clipboard:append({ 'unnamedplus' })

-- vim.opt.cmdheight = 2

-- Reverse global flag (always apply to all, except if /g)
vim.opt.gdefault = true

-- Ignore case in search patterns
vim.opt.ignorecase = true

-- Always show the status line (3 = only the last windows)
vim.opt.laststatus = 2

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

-- Case sensitive when the search contains upper case characters
vim.opt.smartcase = true

vim.opt.termguicolors = true

-- Always show the window bar
-- vim.opt.winbar = ' %t'

-- Window
if vim.fn.has('windows') then
  vim.opt.splitbelow = true -- Split windows below the current window
  vim.opt.splitright = true -- Split windows right of the current window
  vim.opt.winminheight = 0 -- Minimal height of a window when it's not the current one
  -- if vim.opt.tabpagemax < 50 then
  --   vim.opt.tabpagemax = 50 -- Maximum number of tab pages to be opened
  -- end
end

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

local config = {
  colorscheme = 'catppuccin',
  signs = {
    done = '', -- ✓ ✔
    error = '×', -- ✗ ✕
    pending = '→', -- ➜ ➤
    -- info = 'ℹ', -- 
    spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  },
}

local home = os.getenv('HOME')
local node_version = vim.fn.system("mise list node --global --installed | awk '/^node / {print $2}'"):gsub('[\n\r]', '')
local node_major_version = tonumber(string.match(node_version, '^%d+'))
if node_major_version < 20 then
  assert(false, 'node >=20 is required: ' .. node_version)
end
-- mise list node --installed --json --quiet | jq --raw-output 'last .install_path' # /bin/
local node_prefix = home .. '/.local/share/mise/installs/node/' .. node_version .. '/bin/'
if vim.fn.filereadable(node_prefix .. 'node') ~= 1 then
  assert(false, 'node prefix is not readable: ' .. node_prefix)
end
config.node = {
  prefix = node_prefix,
  version = node_version,
}
vim.g.config = config
vim.g.home = home

require('config.lazy')

vim.cmd.colorscheme(vim.g.config.colorscheme)

local local_vimrc = vim.fn.expand('~/.vimrc.local')
if vim.fn.filereadable(local_vimrc) == 1 then
  vim.cmd('source ' .. local_vimrc)
end

local local_vimrc_lua = vim.fn.expand('~/.config/nvim/local.lua')
if vim.fn.filereadable(local_vimrc_lua) == 1 then
  vim.cmd('luafile ' .. local_vimrc_lua)
end
