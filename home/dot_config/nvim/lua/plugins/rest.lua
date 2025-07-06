-- https://github.com/mason-org/mason-lspconfig.nvim/issues/470
return {
  'mistweaverco/kulala.nvim',
  enabled = vim.fn.has('nvim-0.10') == 1,
  tag = 'v5.3.1',
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
}
