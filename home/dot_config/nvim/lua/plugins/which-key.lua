return {
  {
    -- Requires nvim >= 0.9.4
    'folke/which-key.nvim',
    version = '3.17.0',
    event = 'VeryLazy', -- 'ModeChanged',
    opts = {
      preset = 'helix',
    },
    keys = {
      -- WARN: breaks 'gn', use wk.add instead
      -- { 'g', '', desc = '+goto' },

      -- FIXME: prepend relative path expand('%:p:h')
      -- { 'gF', ':e <cfile><cr>', desc = 'Go to file', mode = { 'n', 'v' } },

      -- Helix
      { 'U', ':redo<cr>', desc = 'Redo', mode = { 'n' } },
      { 'ge', 'G', desc = 'Go to last line', mode = { 'n', 'v' } },
      { 'gs', '^', desc = 'First non-blank', mode = { 'n', 'v' } },
      { 'gh', '0', desc = 'Go to line start', mode = { 'n', 'v' } },
      { 'gl', '$', desc = 'Go to line end', mode = { 'n', 'v' } },
      -- { 'mm', '%', desc = 'Go to matching bracket', mode = { 'n', 'v' } },
      -- { '%', 'ggVG', desc = 'Select all', mode = { 'n', 'v' } },

      -- { '.', ':normal n.<cr>', desc = 'Repeat last command', mode = 'v' }, -- as expected in visual mode

      -- TODO: Reflow (gw/gq) and remap <leader>r (Rename symbol)
      { '<backspace>L', ':LspLog<cr>', desc = 'Open LSP logs' },
      -- $HOME/.config/nvim/lua/plugins/lsp.lua
      {
        '<backspace>l',
        ':edit $HOME/.local/share/chezmoi/home/dot_config/nvim/lua/plugins/lsp.lua<cr>',
        desc = 'Edit LSP config',
      },
      -- $MYVIMRC
      { '<backspace>e', ':edit $HOME/.local/share/chezmoi/home/dot_config/nvim/init.lua<cr>', desc = 'Edit config' },
      { '<backspace>r', ':source $MYVIMRC<cr>', desc = 'Reload config' },
      { '<backspace>s', ":'<'>sort<cr>", desc = 'Sort lines', mode = { 'v' } },

      -- Leader

      -- Alternate file or last accessed/modified file
      { '<leader><space>', '<C-^>', desc = 'Last file', mode = { 'n', 'v' } },
      { '<leader>L', '<cmd>Lazy<cr>', desc = 'Lazy' },

      -- See snacks.lua for buffer delete and rename
      { '<leader>bn', ':bnext<cr>', desc = 'Next buffer', mode = { 'n', 'v' } },
      { '<leader>bp', ':bprevious<cr>', desc = 'Previous buffer', mode = { 'n', 'v' } },

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

      -- gt: window top
      -- gc: comment/uncomment
      -- gb: window bottom

      -- Double escape to normal mode
      { '<Esc><Esc>', '<C-\\><C-n>', desc = 'Escape terminal', mode = 't' },
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)
      wk.add({
        -- { '<leader><tab>', group = '+tab' },
        -- { '<leader>c', group = '+code' },
        { '(', group = '+prev' },
        { ')', group = '+next' },
        { '<backspace>', group = '+backspace' },
        { '<space>', group = '+leader' },
        { '[', group = '+prev' },
        { ']', group = '+next' },
        { 'g', group = '+goto' },
        { 'gx', desc = 'Open with system app' },
        { 'p', group = '+paste' },
        { 'z', group = '+fold' },
        {
          '<leader>?',
          function()
            require('which-key').show({ global = false })
          end,
          desc = 'Buffer Local Keymaps (which-key)',
          -- group = 'help',
        },
        {
          '<leader>b',
          group = 'buffers',
          expand = function()
            return require('which-key.extras').expand.buf()
          end,
        },
        {
          '<leader>W',
          group = 'windows',
          proxy = '<c-w>',
          expand = function()
            return require('which-key.extras').expand.win()
          end,
        },
        { '<leader><tab>', group = '+tabs' },
        {
          mode = { 'n', 'v' },
          { '<leader>q', '<cmd>q<cr>', desc = 'Quit editor' },
          { '<leader>w', '<cmd>w<cr>', desc = 'Write file' },
        },
      })
      -- vim.api.nvim_create_autocmd('LspAttach', {
      --   callback = function(args)
      --     if vim.b[args.buf].attached_wk then
      --       return
      --     end
      --     vim.b[args.buf].attached_wk = true
      --     -- local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
      --     -- vim.notify(
      --     --   'Attached: ' .. client.name .. ' (' .. client.id .. ') to buffer ' .. args.buf,
      --     --   vim.log.levels.TRACE,
      --     --   { title = 'LSP' }
      --     -- )
      --     -- https://github.com/neovim/neovim/blob/v0.11.3/runtime/lua/vim/_defaults.lua#L194
      --     -- stylua: ignore
      --   end,
      -- })
      wk.add({
        { 'gr', group = '+lsp' },
        { '<leader>l', group = '+lsp' },
      })
    end,
  },
}
