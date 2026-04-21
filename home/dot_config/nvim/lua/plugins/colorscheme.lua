-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/colorscheme.lua
return {
  {
    'folke/tokyonight.nvim',
    -- version = '4.11.0',
    version = 'v4.x',
    lazy = true,
    opts = {
      dim_inactive = vim.g.config.theme.dim_inactive,
      style = 'storm',
      styles = {
        sidebars = vim.g.config.theme.transparent and 'transparent' or 'dark',
        floats = vim.g.config.theme.transparent and 'transparent' or 'dark',
      },
      transparent = vim.g.config.theme.transparent,
    },
  },
  {
    'rose-pine/neovim',
    tag = 'v3.0.2',
    lazy = true,
    name = 'rose-pine',
    opts = {
      dim_inactive_windows = vim.g.config.theme.dim_inactive,
      styles = {
        transparency = vim.g.config.theme.transparent,
      },
    },
  },
  {
    'EdenEast/nightfox.nvim',
    tag = 'v3.10.0',
    lazy = true,
    opts = {
      options = {
        dim_inactive = vim.g.config.theme.dim_inactive,
        transparent = vim.g.config.theme.transparent,
      },
    },
  },
  {
    'catppuccin/nvim',
    version = 'v2.x',
    lazy = true,
    name = 'catppuccin-nvim',
    opts = {
      flavour = 'macchiato',
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        mini = true,
        navic = { enabled = true, custom_bg = 'lualine' },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        snacks = true,
        telescope = true,
        treesitter_context = true,
        which_key = true,
      },
      --[[ lsp_styles = {
        virtual_text = {
          hints = { 'italic' },
          information = { 'italic' },
          ok = { 'italic' },
        },
        underlines = {
          errors = { 'underline' },
          warnings = { 'underline' },
        },
        inlay_hints = {
          background = false,
        },
      }, ]]
      --
    },
  },
}
