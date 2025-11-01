-- https://github.com/mason-org/mason-lspconfig.nvim/issues/470
return {
  {
    'jellydn/hurl.nvim',
    enabled = vim.g.features.rest,
    version = 'v2.x',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- Optional, for markdown rendering with render-markdown.nvim
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown' },
        },
        ft = { 'markdown' },
      },
    },
    ft = 'hurl',
    opts = {
      -- Show debugging info
      debug = false,
      -- Show notification on run
      show_notification = false,
      -- Show response in popup or split
      mode = 'split',
      -- Default formatter
      formatters = {
        json = { 'jq' }, -- Make sure you have install jq in your system, e.g: brew install jq
        html = {
          'prettier', -- Make sure you have install prettier in your system, e.g: npm install -g prettier
          '--parser',
          'html',
        },
        xml = {
          'tidy', -- Make sure you have installed tidy in your system, e.g: brew install tidy-html5
          '-xml',
          '-i',
          '-q',
        },
      },
      -- Default mappings for the response popup or split views
      mappings = {
        close = 'q', -- Close the response popup or split view
        next_panel = '<C-n>', -- Move to the next response popup window
        prev_panel = '<C-p>', -- Move to the previous response popup window
      },
    },
    keys = {
      -- { '<leader>A', '<cmd>HurlRunner<CR>', desc = 'Run All requests' },
      -- { '<leader>a', '<cmd>HurlRunnerAt<CR>', desc = 'Run Api request' },
      -- { '<leader>te', '<cmd>HurlRunnerToEntry<CR>', desc = 'Run Api request to entry' },
      -- { '<leader>tE', '<cmd>HurlRunnerToEnd<CR>', desc = 'Run Api request from current entry to end' },
      -- { '<leader>tm', '<cmd>HurlToggleMode<CR>', desc = 'Hurl Toggle Mode' },
      -- { '<leader>tv', '<cmd>HurlVerbose<CR>', desc = 'Run Api in verbose mode' },
      -- { '<leader>tV', '<cmd>HurlVeryVerbose<CR>', desc = 'Run Api in very verbose mode' },
      { '<leader>h', ':HurlRunner<CR>', desc = 'Hurl Runner', mode = 'v' },
    },
  },
  {
    'mistweaverco/kulala.nvim',
    enabled = vim.fn.has('nvim-0.10') == 1 and vim.g.features.rest,
    -- tag = 'v5.3.3',
    version = 'v5.x',
    keys = {
      { '<leader>R', '', desc = '+rest' },
      { '<leader>Rs', desc = 'Send request' },
      { '<leader>Ra', desc = 'Send all requests' },
      { '<leader>Rb', desc = 'Open scratchpad' },
    },
    ft = { 'http', 'rest' },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = '<leader>R',
      kulala_keymaps_prefix = '',
      -- urlencode = 'skipencoded',
    },
  },
  {
    'rest-nvim/rest.nvim', -- Requires lua 5.1
    enabled = false, -- vim.g.features.rest,
    -- tag = 'v3.13.0',
    version = 'v3.x',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, 'http')
      end,
    },
  },
}
