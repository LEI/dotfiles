if not vim.fn.has('nvim-0.8') then
  assert(false, 'nvim-0.8 required')
end

-- vim.o.background = 'dark'

vim.opt.clipboard:append({ 'unnamedplus' })

-- Reverse global flag (always apply to all, except if /g)
vim.opt.gdefault = true

-- Ignore case in search patterns
vim.opt.ignorecase = true

-- Always show the status line (3 = only the last windows)
vim.opt.laststatus = 2

-- Show the tab line only if at least 2 pages
vim.opt.showtabline = 1

-- vim.opt.numberwidth = 4

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'

-- Case sensitive when the search contains upper case characters
vim.opt.smartcase = true

vim.opt.termguicolors = true

-- Always show the window bar
vim.opt.winbar = ' %t'

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
    error = '✗', -- × ✕
    pending = '→', -- ➜
    spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  },
}

local home = vim.fn.expand('$HOME') -- os.getenv('HOME')

-- FIXME: should work on wsl
-- TODO: add helper to exec and capture the output of an external command
-- and move to plugin/mise.lua if it is available before lspconfig setup

-- local node_json_cmd = 'mise list node --installed --json --quiet | jq --compact-output --raw-output last'
-- local node_json_result = vim.api.nvim_exec2('!' .. node_json_cmd, { output = true })
-- local node_json = vim.split(node_json_result.output, '\n')[3]
-- local success, node_info = pcall(vim.json.decode, node_json)
-- if success then
--   config.node = {
--     prefix = node_info.install_path .. '/bin/',
--     version = node_info.version,
--   }
-- else
--   config.node = {}
--   dd('Failed to decode node info: ' .. node_json)
-- end
local node_version = '24.3.0'
local node_prefix = home .. '/.local/share/mise/installs/node/' .. node_version .. '/bin/'
if vim.fn.filereadable(node_prefix .. 'node') ~= 1 then
  assert(false, 'node >=20 is required')
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

local local_vimrc_lua = vim.fn.expand('~/.config/nvim/init.lua.local')
if vim.fn.filereadable(local_vimrc_lua) == 1 then
  vim.cmd('luafile ' .. local_vimrc_lua)
end
