-- https://github.com/stevearc/oil.nvim
require('oil').setup({
  delete_to_trash = false,
  -- use_default_keymaps = false,
  view_options = {
    show_hidden = true,
  },
})

-- https://github.com/nvim-lua/plenary.nvim
-- https://github.com/nvim-telescope/telescope.nvim

-- https://github.com/windwp/nvim-autopairs
require('nvim-autopairs').setup()

-- https://github.com/nvim-treesitter/nvim-treesitter
require('nvim-treesitter').setup({
  auto_install = true,
  ensure_installed = "all",
  -- ensure_installed = {
  --   'bash',
  --   'c',
  --   'help',
  --   'html',
  --   'javascript',
  --   'json',
  --   'jsonc',
  --   'lua',
  --   'markdown',
  --   'markdown_inline',
  --   'python',
  --   'query',
  --   'regex',
  --   'tsx',
  --   'typescript',
  --   'vim',
  --   'vimdoc',
  --   'yaml',
  -- },
  highlight = {
    enable = true
  }
})
-- TODO: run once on plugin install or update
vim.cmd('TSUpdate')
