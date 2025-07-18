return {
  {
    'mfussenegger/nvim-ansible',
    enabled = false,
    ft = 'yaml',
    -- stylua: ignore
    keys = {
      { '<leader>te', function() require('ansible').run() end, buffer = true, mode = 'v' },
      { '<leader>te', ":w<CR> :lua require('ansible').run()<CR>", buffer = true, mode = 'n' },
    },
  },
  {
    'folke/lazydev.nvim',
    version = '1.9.0',
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
  -- { 'lervag/vimtex', tag = 'v2.16' },
}
