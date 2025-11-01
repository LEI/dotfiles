-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local map = vim.keymap.set

-- Better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map({ 'n', 'v' }, '<C-h>', '<C-w>h', { desc = 'Go to Left Window', remap = true })
map({ 'n', 'v' }, '<C-j>', '<C-w>j', { desc = 'Go to Lower Window', remap = true })
map({ 'n', 'v' }, '<C-k>', '<C-w>k', { desc = 'Go to Upper Window', remap = true })
map({ 'n', 'v' }, '<C-l>', '<C-w>l', { desc = 'Go to Right Window', remap = true })

-- Resize window using <ctrl> arrow keys
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- Move Lines
-- map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
-- map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
-- map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
-- map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
-- map('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
-- map('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- Buffers
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '(b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', ')b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
-- map('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
-- map('n', '<leader>`', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
if not Snacks then
  map('n', '<leader>bd', '<cmd>:bd<cr>', { desc = 'Delete Buffer' })
  map('n', '<leader>bo', '<cmd>:%bd|e#<cr>', { desc = 'Delete Other Buffers' })
end
map('n', '<leader>bD', '<cmd>:bd<cr>', { desc = 'Delete Buffer and Window' })

-- Clear search and stop snippet on escape
-- map({ 'i', 'n', 's' }, '<esc>', function()
--   vim.cmd('noh')
--   LazyVim.cmp.actions.snippet_stop()
--   return '<esc>'
-- end, { expr = true, desc = 'Escape and Clear hlsearch' })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  'n',
  '<leader>ur',
  '<cmd>nohlsearch<bar>diffupdate<bar>normal! <C-L><cr>',
  { desc = 'Redraw / Clear hlsearch / Diff Update' }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- Add undo break-points
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- Save file
-- map({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })

--keywordprg
map('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })

-- { ';', ':normal n.<cr>', desc = 'Repeat last command on next match', mode = 'n' },
map('n', ';', ':normal n.<cr>')
-- { '.', ':normal.<cr>', desc = 'Repeat last command', mode = 'v' },
map('v', '.', ':normal.<cr>')

-- Keep visual mode after indenting
-- map('v', '<', '<gv')
-- map('v', '>', '>gv')

-- Commenting
map('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
map('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })

-- Location list
map('n', '<leader>xl', function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Location List' })

-- Quickfix list
map('n', '<leader>xq', function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = 'Quickfix List' })

map('n', '(q', '<cmd>cprev<cr>', { desc = 'Previous quickfix' })
map('n', ')q', '<cmd>cnext<cr>', { desc = 'Next quickfix' })

-- Quit
-- map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- Highlights under cursor
map('n', '<leader>ui', function()
  vim.show_pos()
end, { desc = 'Inspect pos' })
map('n', '<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input('I')
end, { desc = 'Inspect tree' })

-- Terminal Mappings
map('t', '<C-/>', '<cmd>close<cr>', { desc = 'Hide Terminal' })
map('t', '<c-_>', '<cmd>close<cr>', { desc = 'which_key_ignore' })

-- Windows
map('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
-- map('n', '<leader>wd', '<C-W>c', { desc = 'Delete Window', remap = true })
-- Snacks.toggle.zoom():map('<leader>wm'):map('<leader>uZ')
-- Snacks.toggle.zen():map('<leader>uz')

-- Tabs
map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

-- Native snippets. only needed on < 0.11, as 0.11 creates these by default
if vim.fn.has('nvim-0.11') == 0 then
  map('s', '<Tab>', function()
    return vim.snippet.active({ direction = 1 }) and '<cmd>lua vim.snippet.jump(1)<cr>' or '<Tab>'
  end, { expr = true, desc = 'Jump Next' })
  map({ 'i', 's' }, '<S-Tab>', function()
    return vim.snippet.active({ direction = -1 }) and '<cmd>lua vim.snippet.jump(-1)<cr>' or '<S-Tab>'
  end, { expr = true, desc = 'Jump Previous' })
end

local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', ')d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
map('n', '(d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
map('n', ')e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
map('n', '(e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
map('n', ')w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
map('n', '(w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })

-- Refresh buffer
map('n', '<M-l>', '<cmd>edit<cr>', { desc = 'Refresh buffer' })

-- Vertical split
-- T: ":silent !tmux split-window"
-- '"': ":silent !tmux split-window"
-- Horizontal split
-- "%": ":silent !tmux split-window -h"
-- Repeat last command in the previously selected tmux pane
-- Send enter twice if shell expands '!!'
map('n', '<leader>t', ':silent !repeat-last-command<cr>', {
  desc = 'Repeat last command in last pane',
  -- silent = true,
})

if not Snacks then
  return
end

-- Set keymap for buffers with any LSP that supports code actions
-- client.server_capabilities.codeActionProvider
-- gra: vim.lsp.buf.code_action
Snacks.keymap.set({ 'n', 'v', 'x' }, '<leader>ca', vim.lsp.buf.code_action, {
  lsp = { method = 'textDocument/codeAction' },
  desc = 'Code action',
})

-- Set keymap for buffers with a specific LSP client
Snacks.keymap.set('n', '<leader>co', function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { 'source.organizeImports' },
      diagnostics = {},
    },
  })
end, {
  lsp = { name = 'vtsls' },
  desc = 'Organize imports',
})

-- -- Set keymap for buffers with LSP that supports definitions
-- Snacks.keymap.set('n', 'gd', vim.lsp.buf.definition, {
--   lsp = { method = 'textDocument/definition' },
--   desc = 'Go to Definition',
-- })
Snacks.keymap.set('n', 'gd', Snacks.picker.lsp_definitions, {
  lsp = { method = 'textDocument/definition' },
  desc = 'Go to definition',
})
Snacks.keymap.set('n', 'gD', Snacks.picker.lsp_declarations, {
  lsp = { method = 'textDocument/declaration' },
  desc = 'Go to declaration',
})
-- grr: vim.lsp.buf.references
Snacks.keymap.set('n', 'grR', Snacks.picker.lsp_references, {
  lsp = { method = 'textDocument/references' },
  -- nowait = true,
  desc = 'References',
})
-- gri: vim.lsp.buf.implementation
Snacks.keymap.set('n', 'gI', Snacks.picker.lsp_implementations, {
  lsp = { method = 'textDocument/implementation' },
  desc = 'Go to implementation',
})
-- grt: vim.lsp.buf.type_definition
Snacks.keymap.set('n', 'gy', Snacks.picker.lsp_type_definitions, {
  lsp = { method = 'textDocument/typeDefinition' },
  desc = 'Go to type definition',
})

-- -- NOTE: already mapped to 'K'
-- Snacks.keymap.set('n', '<leader>k', vim.lsp.buf.hover, {
--   lsp = { method = 'textDocument/hover' },
--   desc = 'Show docs for item under the cursor',
-- })

-- grn: vim.lsp.buf.rename
Snacks.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, {
  lsp = { method = 'textDocument/rename' },
  desc = 'Rename',
})

Snacks.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help, {
  lsp = { method = 'textDocument/signatureHelp' },
  desc = 'Signature help',
})

Snacks.keymap.set('n', '<leader>lc', function()
  Snacks.picker.lsp_config()
end, { desc = 'Search LSP configurations' })

Snacks.keymap.set('n', '<leader>ls', function()
  Snacks.picker.lsp_symbols()
end, {
  lsp = { method = 'textDocument/documentSymbol' },
  desc = 'LSP symbols',
})

Snacks.keymap.set('n', '<leader>lS', function()
  Snacks.picker.lsp_workspace_symbols()
end, {
  lsp = { method = 'workspace/symbol' },
  desc = 'LSP workspace symbols',
})

-- -- FIXME: <leader>r conflicts with +refactor
-- -- lua
-- Snacks.keymap.set({ 'n', 'x' }, '<localleader>r', function()
--   Snacks.debug.run()
-- end, { desc = 'Run Lua', ft = 'lua' })

-- Snacks.keymap.set('n', '<leader>t', ':TestNearest<cr>', {
--   ft = { 'python', 'ruby', 'javascript' },
--   desc = 'Run Test',
-- })
