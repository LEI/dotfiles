-- https://github.com/folke/which-key.nvim
local wk = require('which-key')

wk.setup({
  preset = 'helix',
})

-- TODO: remap <leader>r (Rename symbol) to reload (or <backspace>r)
wk.add({
  { '<Esc>',        '<C-\\><C-n>',          desc = 'Escape terminal',               mode = 't',         noremap = true },

  { '<C-h>',        '<C-w>h',               desc = 'Left window',                   mode = { 'n', 'v' } },
  { '<C-j>',        '<C-w>j',               desc = 'Up window',                     mode = { 'n', 'v' } },
  { '<C-k>',        '<C-w>k',               desc = 'Down window',                   mode = { 'n', 'v' } },
  { '<C-l>',        '<C-w>l',               desc = 'Right window',                  mode = { 'n', 'v' } },

  { 'U',            ':redo<cr>',            desc = 'Redo',                          mode = { 'n', 'v' } },
  { 'ge',           'G',                    desc = 'Go to last line',               mode = { 'n', 'v' } },
  { 'gs',           '^',                    desc = 'Go to first non-blank in line', mode = { 'n', 'v' } },
  { 'gh',           '0',                    desc = 'Go to line start',              mode = { 'n', 'v' } },
  { 'gl',           '$',                    desc = 'Go to line end',                mode = { 'n', 'v' } },

  { '<backspace>o', ':open $MYVIMRC<cr>',   desc = 'Open config' },
  { '<backspace>r', ':source $MYVIMRC<cr>', desc = 'Reload config' },
  { '<backspace>s', ':\'<\'>sort<cr>',      desc = 'Sort lines',                    mode = { 'v' } },

  {
    '<leader>\'',
    require('telescope.builtin').resume,
    desc = 'Open last picker',
    mode = { 'n', 'v' },
  },
  {
    '<leader>"',
    require('telescope.builtin').pickers,
    desc = 'Open cached pickers',
    mode = { 'n', 'v' },
  },
  {
    '-',
    -- Open telescope find_files in current buffer directory
    -- https://github.com/nvim-telescope/telescope.nvim/issues/2201
    -- '<cmd>Telescope find_files search_dirs={"%:h"}<cr>', -- vim.fn.expand("%:h")
    '<cmd>Oil<cr>',
    desc = 'Open parent directory',
    mode = { 'n', 'v' },
  },
  -- Alternate file or last accessed/modified file
  { '<leader><space>', '<C-^>',               desc = 'Last file', mode = { 'n', 'v' } },

  { '<leader>B',       '<cmd>DBUIToggle<cr>', desc = 'DBUI',      mode = { 'n', 'v' } },
  {
    '<leader>G',
    -- '<cmd>Debug<cr>',
    -- desc = 'Debug',
    -- mode = { 'n', 'v' },
    group = 'debug',
    expand = function()
      return require('which-key.extras').expand.buf()
    end
  },
  { '<leader>H', '<cmd>MCPHub<cr>',              desc = 'MCPHub',    mode = { 'n', 'v' } },
  { '<leader>h', '<cmd>Telescope help_tags<cr>', desc = 'Help tags', mode = { 'n', 'v' } },
  { '<leader>M', '<cmd>Mason<cr>',               desc = 'Mason',     mode = { 'n', 'v' } },
  { '<leader>O', '<cmd>Oil<cr>',                 desc = 'Oil',       mode = { 'n', 'v' } },
  -- { '<leader>S', '<cmd>AerialToggle!<cr>', desc = 'Toggle symbols', mode = { 'n', 'v' } },
  { '<leader>T', '<cmd>Telescope<cr>',           desc = 'Telescope', mode = { 'n', 'v' } },
  { '<leader>U', '<cmd>UndotreeToggle<cr>',      desc = 'Undo tree', mode = { 'n', 'v' } },

  {
    '<leader>s',
    '<cmd>belowright split<cr>',
    desc = 'Split down',
    mode = { 'n', 'v' },
  },
  {
    '<leader>t',
    '<cmd>belowright split | resize 20 | terminal<cr>i',
    desc = 'Terminal',
    mode = { 'n', 'v' },
  },
  {
    '<leader>v',
    '<cmd>belowright vsplit<cr>',
    desc = 'Split right',
    mode = { 'n', 'v' },
  },

  {
    '<leader>b',
    group = 'buffers',
    expand = function()
      return require('which-key.extras').expand.buf()
    end
  },


  { '<leader>D', '<cmd>Telescope diagnostics<cr>',         desc = 'Workspace diagnostics', mode = { 'n', 'v' } },
  { '<leader>d', '<cmd>Telescope diagnostics bufnr=0<cr>', desc = 'Diagnostics',           mode = { 'n', 'v' } },
  {
    '<leader>E',
    -- TODO: depth=1
    '<cmd>Telescope find_files search_dirs={"%:h"}<cr>',
    desc = 'Open file explorer at current buffer\'s directory',
    mode = { 'n', 'v' },
  },
  {
    '<leader>e',
    '<cmd>Telescope find_files<cr>',
    desc = 'Open file explorer in workspace root',
    mode = { 'n', 'v' },
  },

  -- { '<leader>f',  group = 'file' }, -- group
  -- {
  --   '<leader>F',
  --   '<cmd>Telescope find_files<cr>',
  --   desc = 'Find file at current working directory',
  --   mode = {'n', 'v'},
  -- },
  { '<leader>/',  '<cmd>Telescope live_grep<cr>',    desc = 'Search files',         mode = { 'n', 'v' } },
  { '<leader>f',  '<cmd>Telescope find_files<cr>',   desc = 'Find file',            mode = { 'n', 'v' } },
  { '<leader>g',  '<cmd>Telescope grep_string<cr>',  desc = 'Grep string',          mode = { 'n', 'v' } },
  { '<leader>n',  '<cmd>Telescope fidget<cr>',       desc = 'Notification history', mode = { 'n', 'v' } },

  { '<leader>X',  '<cmd>Trouble<cr>',                desc = 'Trouble',              mode = { 'n', 'v' } },
  { '<leader>xs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)',    mode = { 'n', 'v' } },
  {
    '<leader>xx',
    '<cmd>Trouble diagnostics toggle<cr>',
    desc = 'Diagnostics (Trouble)',
  },
  {
    '<leader>xX',
    '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
    desc = 'Buffer Diagnostics (Trouble)',
  },
  {
    '<leader>cs',
    '<cmd>Trouble symbols toggle focus=false<cr>',
    desc = 'Symbols (Trouble)',
  },
  {
    '<leader>cl',
    '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
    desc = 'LSP Definitions / references / ... (Trouble)',
  },
  {
    '<leader>xL',
    '<cmd>Trouble loclist toggle<cr>',
    desc = 'Location List (Trouble)',
  },
  {
    '<leader>xQ',
    '<cmd>Trouble qflist toggle<cr>',
    desc = 'Quickfix List (Trouble)',
  },

  -- { '<leader>fb', function() print('hello') end,   desc = 'Foobar' },
  -- { '<leader>fn', desc = 'New File' },
  -- { '<leader>f1', hidden = true },

  -- client.server_capabilities.codeActionProvider
  {
    '<leader>a',
    vim.lsp.buf.code_action,
    desc = 'Code Action',
    mode = { 'n', 'v' },
  },
  -- client.server_capabilities.hoverProvider
  {
    '<leader>k',
    vim.lsp.buf.hover,
    desc = 'Show docs for item under the cursor',
    mode = 'n',
  },

  -- {
  --   -- Proxy to window mappings
  --   '<leader>w',
  --   proxy = '<c-w>',
  --   group = 'windows',
  -- },
  {
    -- Nested mappings are allowed and can be added in any order
    -- Most attributes can be inherited or overridden on any level
    -- There's no limit to the depth of nesting
    mode = { 'n', 'v' },                                 -- NORMAL and VISUAL mode
    { '<leader>q', '<cmd>q<cr>', desc = 'Quit editor' }, -- no need to specify mode since it's inherited
    { '<leader>w', '<cmd>w<cr>', desc = 'Write file' },
  },

  -- client.server_capabilities.definitionsProvider
  { 'gd',    vim.lsp.buf.definition,      desc = 'Go to definition',      mode = 'n' },
  { 'gD',    vim.lsp.buf.declaration,     desc = 'Go to declaration',     mode = 'n' },
  { 'gy',    vim.lsp.buf.type_definition, desc = 'Go to type definition', mode = 'n' },
  -- client.server_capabilities.renameProvider
  { 'gR',    vim.lsp.buf.rename,          desc = 'Rename',                mode = 'n' },
  -- NOTE: gr conflicts with gr{a,i,n,r} from _defaults.lua
  -- client.server_capabilities.referencesProvider
  -- { 'gr',    vim.lsp.buf.references,      desc = 'Go to references',      mode = 'n' },
  -- client.server_capabilities.implementationProvider
  { 'gi',    vim.lsp.buf.implementation,  desc = 'Go to implementation',  mode = 'n' },
  -- client.server_capabilities.signatureHelpProvider
  { '<C-s>', vim.lsp.buf.signature_help,  desc = 'Signature help',        mode = 'i' },

  -- gt: window top
  -- gc: comment/uncomment
  -- gb: window bottom
})
