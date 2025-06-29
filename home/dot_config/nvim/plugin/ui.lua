local diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = 'x',
  [vim.diagnostic.severity.WARN] = '!',
  [vim.diagnostic.severity.INFO] = 'i',
  [vim.diagnostic.severity.HINT] = '?',
}

vim.diagnostic.config({
  signs = {
    text = diagnostic_signs,
    -- linehl = {
    --   [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
    -- },
    -- numhl = {
    --   [vim.diagnostic.severity.WARN] = 'WarningMsg',
    -- },
  },
})

-- https://github.com/stevearc/aerial.nvim
-- require('aerial').setup()

-- https://github.com/akinsho/bufferline.nvim
-- require('bufferline').setup()

-- https://github.com/j-hui/fidget.nvim
require('fidget').setup()

-- https://github.com/lewis6991/gitsigns.nvim
require('gitsigns').setup({
  current_line_blame = true,
})

-- https://github.com/folke/trouble.nvim
local trouble = require('trouble')
trouble.setup()

-- Automatically open Trouble quickfix
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
  callback = function()
    vim.cmd('Trouble qflist open')
  end,
})

-- https://github.com/nvim-lualine/lualine.nvim
require('lualine').setup({
  options = {
    icons_enabled = false,
    component_separators = '',
    section_separators = '',
    -- disabled_filetypes = {
    --   statusline = {},
    --   winbar = {},
    -- },
    -- ignore_focus = {},
    -- always_divide_middle = true,
    -- always_show_tabline = true,
    -- globalstatus = false,
    -- refresh = {
    --   statusline = 1000,
    --   tabline = 1000,
    --   winbar = 1000,
    --   refresh_time = 16, -- ~60fps
    --   events = {
    --     'WinEnter',
    --     'BufEnter',
    --     'BufWritePost',
    --     'SessionLoadPost',
    --     'FileChangedShellPost',
    --     'VimResized',
    --     'Filetype',
    --     'CursorMoved',
    --     'CursorMovedI',
    --     'ModeChanged',
    --   },
    -- },
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str) return str:sub(1, 3) end,
      },
    },
    lualine_b = {
      {
        'branch',
        -- color = '',
        -- icon = '',
      },
      {
        'diff',
        -- colored = false,
        -- symbols = {
        --   added = '+',
        --   modified = '~',
        --   removed = '-',
        -- },
      },
    },
    lualine_c = {
      { 'filename', path = 1 },
    },
    lualine_x = {
      'codecompanion',
      'codeium#GetStatusString',
      'copilot',
      {
        'lsp_status',
        -- icon = '', -- f013
        -- symbols = {
        --   spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
        --   done = '✓',
        --   separator = ' ',
        -- },
        -- ignore_lsp = {},
      },
      {
        'diagnostics',
        -- always_visible = true,
        symbols = {
          error = diagnostic_signs[vim.diagnostic.severity.ERROR],
          warn = diagnostic_signs[vim.diagnostic.severity.WARN],
          info = diagnostic_signs[vim.diagnostic.severity.INFO],
          hint = diagnostic_signs[vim.diagnostic.severity.HINT],
        },
      },
      'progress',
      'location',
      {
        'encoding',
        cond = function() return vim.o.encoding ~= 'utf-8' end,
        show_bom = true,
      },
      {
        'fileformat',
        -- fmt = function(str) return str == 'unix' and 'LF' or str end,
      },
      'filetype',
    },
    lualine_y = {
      -- 'progress',
    },
    lualine_z = {
      -- 'location',
    },
  },
  -- inactive_sections = {
  --   lualine_a = {},
  --   lualine_b = {},
  --   lualine_c = { 'filename' },
  --   lualine_x = { 'location' },
  --   lualine_y = {},
  --   lualine_z = {}
  -- },
  tabline = {
    -- lualine_a = { 'buffers' },
    -- lualine_b = { 'branch' },
    lualine_c = {
      'buffers',
      -- 'filename',
    },
    -- lualine_x = {},
    -- lualine_y = {},
    -- lualine_z = { 'tabs' }
  },
  -- winbar = { lualine_c = { 'filename' } },
  -- inactive_winbar = { lualine_c = { 'filename' } },

  -- https://github.com/nvim-lualine/lualine.nvim#available-extensions
  extensions = {
    -- 'aerial',
    -- 'assistant',
    'fugitive',
    'mason',
    'nvim-dap-ui',
    'oil',
    'quickfix',
    'trouble',
  }
})
