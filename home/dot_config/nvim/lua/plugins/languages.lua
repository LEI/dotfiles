return {
  {
    'mfussenegger/nvim-ansible',
    enabled = false,
    ft = 'yaml',
    -- stylua: ignore
    keys = {
      { '<leader>Ae', function() require('ansible').run() end, buffer = true, mode = 'v' },
      { '<leader>Ae', ":w<CR> :lua require('ansible').run()<CR>", buffer = true, mode = 'n' },
    },
  },
  {
    'folke/lazydev.nvim',
    enabled = vim.fn.has('nvim-0.10') == 1,
    -- version = '1.9.0',
    version = 'v1.x',
    ft = 'lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        -- { path = 'LazyVim', words = { 'LazyVim' } },
        -- { path = 'lazy.nvim', words = { 'LazyVim' } },
        { path = 'snacks.nvim', words = { 'Snacks' } },
        'nvim-dap-ui',
      },
    },
  },
  {
    'ricardoramirezr/blade-nav.nvim',
    dependencies = {
      'saghen/blink.cmp',
    },
    ft = { 'blade', 'php' },
    opts = {},
  },
  -- { 'lervag/vimtex', tag = 'v2.16' },
}
