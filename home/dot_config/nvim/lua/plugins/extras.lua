return {
  { 'MunifTanjim/nui.nvim', tag = '0.4.0', lazy = true },
  { 'nvim-lua/plenary.nvim', tag = 'v0.1.4', lazy = true },
  {
    'nvim-neotest/nvim-nio',
    -- tag = 'v1.10.1',
    version = 'v1.x',
    lazy = true,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    -- tag = 'v8.6.0',
    version = 'v8.x',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.icons',
    },
    ft = 'markdown',
    opts = {
      code = { enabled = false }, -- FIXME: conceal_delimiters = false
      completions = { lsp = { enabled = false } }, -- FIXME: Invalid server name 'render-markdown'
      file_types = { 'markdown', 'codecompanion', 'Avante' },
      html = { comment = { conceal = false } },
      link = { enabled = false },
      only_render_image_at_cursor = true,
      preset = 'lazy',
    },
  },
  {
    'HakonHarnes/img-clip.nvim',
    tag = 'v0.6.0',
    cmd = 'PasteImage',
    keys = {
      { '<leader>pi', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    },
    opts = {
      -- Recommended settings
      default = {
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        -- Required for Windows users
        use_absolute_path = true,
      },
    },
  },
  {
    'echasnovski/mini.icons',
    tag = 'v0.16.0',
    lazy = true,
    opts = {
      file = {
        ['.chezmoiignore'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['.chezmoiremove'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['.chezmoiroot'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['.chezmoiversion'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['bash.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['json.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['ps1.tmpl'] = { glyph = '󰨊', hl = 'MiniIconsGrey' },
        ['sh.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['toml.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['yaml.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['zsh.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
      },
      style = vim.g.config.preset == 'font' and 'glyph' or 'ascii',
    },
  },
}
