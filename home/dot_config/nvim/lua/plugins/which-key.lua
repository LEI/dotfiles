return {
  {
    -- Requires nvim >= 0.9.4
    'folke/which-key.nvim',
    version = '3.17.0',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show({ global = false })
        end,
        desc = 'Buffer Local Keymaps (which-key)',
        -- NOTE: which-key only
        -- group = 'help',
      },
      { ';', ':normal n.<cr>', desc = 'Repeat last command', mode = 'n', noremap = true }, -- on next match
    },
    init = function()
      require('which-key').add({
        -- { '.', ':normal n.<cr>', desc = 'Repeat last command', mode = 'v', noremap = true }, -- as expected in visual mode

        -- Split navigation shortcuts
        { '<C-h>', '<C-w>h', desc = 'Left window', mode = { 'n', 'v' } },
        { '<C-j>', '<C-w>j', desc = 'Up window', mode = { 'n', 'v' } },
        { '<C-k>', '<C-w>k', desc = 'Down window', mode = { 'n', 'v' } },
        { '<C-l>', '<C-w>l', desc = 'Right window', mode = { 'n', 'v' } },

        { 'U', ':redo<cr>', desc = 'Redo', mode = { 'n', 'v' } },
        { 'ge', 'G', desc = 'Go to last line', mode = { 'n', 'v' } },
        { 'gs', '^', desc = 'First non-blank', mode = { 'n', 'v' } },
        { 'gh', '0', desc = 'Go to line start', mode = { 'n', 'v' } },
        { 'gl', '$', desc = 'Go to line end', mode = { 'n', 'v' } },

        -- TODO: Reflow (gw/gq) and remap <leader>r (Rename symbol) to reload (or <backspace>r)
        { '<backspace>o', ':edit $MYVIMRC<cr>', desc = 'Edit config' },
        { '<backspace>r', ':source $MYVIMRC<cr>', desc = 'Reload config' },
        { '<backspace>s', ":'<'>sort<cr>", desc = 'Sort lines', mode = { 'v' } },

        -- Alternate file or last accessed/modified file
        { '<leader><space>', '<C-^>', desc = 'Last file', mode = { 'n', 'v' } },
        { '<leader>L', '<cmd>Lazy<cr>', desc = 'Lazy' },
        -- { '<leader>h', '<cmd>Gitsigns setqflist<cr>', desc = 'Git hunks (QF list)' },
        -- { '<leader>S', '<cmd>AerialToggle!<cr>', desc = 'Toggle symbols' },

        -- { '<leader>s', '<cmd>belowright split<cr>', desc = 'Split down' },
        -- { '<leader>v', '<cmd>belowright vsplit<cr>', desc = 'Split right' },

        {
          '<leader>b',
          group = 'buffers',
          expand = function()
            return require('which-key.extras').expand.buf()
          end,
        },

        {
          ')d',
          function()
            vim.diagnostic.jump({ count = 1, float = true })
          end,
          desc = 'Next diagnostic',
          mode = { 'n', 'v' },
        },
        {
          '(d',
          function()
            vim.diagnostic.jump({ count = -1, float = true })
          end,
          desc = 'Next diagnostic',
          mode = { 'n', 'v' },
        },

        -- TODO: on lsp attach

        -- {
        --   '<leader>E',
        --   -- TODO: depth=1
        --   '<cmd>Telescope find_files search_dirs={"%:h"}<cr>',
        --   desc = "Open file explorer at current buffer's directory",
        --   mode = { 'n', 'v' },
        -- },
        -- {
        --   '<leader>e',
        --   '<cmd>Telescope find_files<cr>',
        --   desc = 'Open file explorer in workspace root',
        --   mode = { 'n', 'v' },
        -- },

        -- { '<leader>f',  group = 'file' }, -- group
        -- {
        --   '<leader>F',
        --   '<cmd>Telescope find_files<cr>',
        --   desc = 'Find file at current working directory',
        --   mode = {'n', 'v'},
        -- },
        -- { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Search files", mode = { "n", "v" } },
        -- { '<leader>f', '<cmd>Telescope find_files<cr>', desc = 'Find file', mode = { 'n', 'v' } },
        -- { '<leader>g', '<cmd>Telescope grep_string<cr>', desc = 'Grep string', mode = { 'n', 'v' } },
        -- { '<leader>N', '<cmd>Telescope fidget<cr>', desc = 'Notification history', mode = { 'n', 'v' } },
        -- { '<leader>n', '<cmd>Fidget history<cr>', desc = 'Notification history', mode = { 'n', 'v' } },

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
        -- NOTE: already mapped to 'K'
        -- client.server_capabilities.hoverProvider
        -- { '<leader>k', vim.lsp.buf.hover, desc = 'Show docs for item under the cursor', mode = 'n' },

        -- {
        --   -- Proxy to window mappings
        --   '<leader>w',
        --   proxy = '<c-w>',
        --   group = 'windows',
        -- },
        {
          mode = { 'n', 'v' },
          { '<leader>q', '<cmd>q<cr>', desc = 'Quit editor' },
          { '<leader>w', '<cmd>w<cr>', desc = 'Write file' },
        },

        -- client.server_capabilities.definitionsProvider
        { 'gd', vim.lsp.buf.definition, desc = 'Go to definition', mode = 'n' },
        { 'gD', vim.lsp.buf.declaration, desc = 'Go to declaration', mode = 'n' },
        { 'gy', vim.lsp.buf.type_definition, desc = 'Go to type definition', mode = 'n' },
        -- client.server_capabilities.renameProvider
        { 'gR', vim.lsp.buf.rename, desc = 'Rename', mode = 'n' },
        -- NOTE: gr conflicts with gr{a,i,n,r} from _defaults.lua
        -- client.server_capabilities.referencesProvider
        -- { 'gr',    vim.lsp.buf.references,      desc = 'Go to references',      mode = 'n' },
        -- client.server_capabilities.implementationProvider
        { 'gi', vim.lsp.buf.implementation, desc = 'Go to implementation', mode = 'n' },
        -- client.server_capabilities.signatureHelpProvider
        { '<C-s>', vim.lsp.buf.signature_help, desc = 'Signature help', mode = 'i' },

        -- gt: window top
        -- gc: comment/uncomment
        -- gb: window bottom

        -- Double escape to normal mode
        { '<Esc><Esc>', '<C-\\><C-n>', desc = 'Escape terminal', mode = 't', noremap = true },
      })
    end,
  },
}
