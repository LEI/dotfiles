local spinner = vim.g.config.signs.spinner
-- local spinner_len = #spinner

vim.diagnostic.config({
  float = {
    source = true, -- 'if_many',
  },
  severity_sort = true,
  signs = {
    text = vim.g.diagnostic_signs,
    -- linehl = {
    --   [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
    -- },
    -- numhl = {
    --   [vim.diagnostic.severity.WARN] = 'WarningMsg',
    -- },
  },
  virtual_lines = false,
  -- virtual_lines = FIXME: vim.g.ai.sidekick and false or {
  --   current_line = true,
  -- },
  virtual_text = {
    -- FIXME: does not hide current line virtual text
    current_line = false,
    prefix = vim.g.config.signs.on,
  },
})

-- require('bufferline').setup()

return {
  -- Alternative: ecthelionvi/NeoColumn.nvim
  -- {
  --   'Bekaboo/deadcolumn.nvim',
  --   tag = 'v1.0.2',
  --   opts = {
  --     modes = function()
  --       return true
  --     end,
  --     extra = { follow_tw = '+1' },
  --   },
  --   init = function()
  --     vim.api.nvim_create_autocmd('BufEnter', {
  --       pattern = '*',
  --       command = 'setlocal colorcolumn=120',
  --     })
  --   end,
  -- },
  {
    'm4xshen/smartcolumn.nvim',
    -- tag = 'v1.1.1',
    version = 'v1.x',
    event = 'VeryLazy',
    opts = {
      colorcolumn = '80',
      disabled_filetypes = {
        'Trouble',
        'checkhealth',
        'fish',
        'help',
        'lazy',
        'lspinfo',
        'markdown',
        'mason',
        'noice',
        'snacks_dashboard',
        'text',
        'zsh',
      },
      scope = 'file', -- file, window or line
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    version = vim.fn.has('nvim-0.11') == 1 and 'v2.x' or 'v1.x',
    dependencies = { 'folke/snacks.nvim' },
    cmd = 'Gitsigns',
    event = {
      -- 'CursorHold',
      'VeryLazy',
    },
    -- stylua: ignore
    keys = {
      -- { '<leader>gh', desc = '+hunks' },
      { '<leader>gh', '<cmd>Gitsigns setqflist<cr>', desc = 'Git hunks (QF list)' },
      { ')h', '<cmd>Gitsigns next_hunk<cr>', desc = 'Next hunk', mode = { 'n', 'v' } },
      { '(h', '<cmd>Gitsigns prev_hunk<cr>', desc = 'Next hunk', mode = { 'n', 'v' } },
    },
    opts = function()
      Snacks.toggle({
        name = 'Git Signs',
        get = function()
          return require('gitsigns.config').config.signcolumn
        end,
        set = function(state)
          require('gitsigns').toggle_signs(state)
        end,
      }):map('<leader>uG')
      return {
        current_line_blame = true,
      }
    end,
  },

  {
    'folke/todo-comments.nvim',
    -- tag = 'v1.5.0',
    version = 'v1.x',
    dependencies = {
      'folke/snacks.nvim',
      'nvim-lua/plenary.nvim',
    },
    cmd = {
      -- 'TodoFzfLua',
      -- 'TodoLocList',
      -- 'TodoQuickFix',
      -- 'TodoTelescope',
      'TodoTrouble',
    },
    event = {
      -- 'CursorHold',
      'VeryLazy',
    },
    -- stylua: ignore
    keys = {
      { ']t', function() require('todo-comments').jump_next() end, desc = 'Next Todo Comment' },
      { '[t', function() require('todo-comments').jump_prev() end, desc = 'Previous Todo Comment' },
      { '<leader>xt', '<cmd>Trouble todo toggle<cr>', desc = 'Todo (Trouble)' },
      -- { '<leader>xT', '<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>', desc = 'Todo/Fix/Fixme (Trouble)' },
      -- { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
      -- { '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = 'Todo/Fix/Fixme' },
      -- { '<leader>st', '<cmd>TodoTelescope<cr>', desc = 'Todo' },
      -- { '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>', desc = 'Todo/Fix/Fixme' },
      { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
      { '<leader>sT', function() Snacks.picker.todo_comments({ keywords = { 'TODO', 'FIX', 'FIXME' } }) end, desc = 'Todo/Fix/Fixme' },
    },
    opts = {
      signs = true, -- show icons in the signs column
      -- sign_priority = 8, -- sign priority
      -- -- keywords recognized as todo comments
      keywords = {
        FIX = {
          icon = vim.g.config.signs.comments.fix, -- icon used for the sign, and in search results
          color = 'error', -- can be a hex color, or a named color (see below)
          alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = vim.g.config.signs.comments.todo, color = 'info' },
        HACK = { icon = vim.g.config.signs.comments.hack, color = 'warning' },
        WARN = { icon = vim.g.config.signs.comments.warn, color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = vim.g.config.signs.comments.perf, alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = vim.g.config.signs.comments.note, color = 'hint', alt = { 'INFO' } },
        TEST = { icon = vim.g.config.signs.comments.test, color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
      },
      -- gui_style = {
      --   fg = 'NONE', -- The gui style to use for the fg highlight group.
      --   bg = 'BOLD', -- The gui style to use for the bg highlight group.
      -- },
      -- merge_keywords = true, -- when true, custom keywords will be merged with the defaults

      -- highlighting of the line containing the todo comment
      -- * before: highlights before the keyword (typically comment characters)
      -- * keyword: highlights of the keyword
      -- * after: highlights after the keyword (todo text)
      highlight = {
        multiline = false, -- true, -- enable multine todo comments
        -- multiline_pattern = '^.', -- lua pattern to match the next multiline from the start of the matched keyword
        -- multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
        -- before = '', -- "fg" or "bg" or empty
        -- keyword = 'wide', -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        -- after = 'fg', -- "fg" or "bg" or empty
        -- pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
        -- comments_only = true, -- uses treesitter to match keywords in comments only
        -- max_line_len = 400, -- ignore lines longer than this
        -- exclude = {}, -- list of file types to exclude highlighting
      },

      -- -- list of named colors where we try to extract the guifg from the
      -- -- list of highlight groups or use the hex color if hl not found as a fallback
      -- colors = {
      --   error = { 'DiagnosticError', 'ErrorMsg', '#DC2626' },
      --   warning = { 'DiagnosticWarn', 'WarningMsg', '#FBBF24' },
      --   info = { 'DiagnosticInfo', '#2563EB' },
      --   hint = { 'DiagnosticHint', '#10B981' },
      --   default = { 'Identifier', '#7C3AED' },
      --   test = { 'Identifier', '#FF00FF' },
      -- },
      -- search = {
      --   command = 'rg',
      --   args = {
      --     '--color=never',
      --     '--no-heading',
      --     '--with-filename',
      --     '--line-number',
      --     '--column',
      --   },
      --   -- regex that will be used to match keywords.
      --   -- don't replace the (KEYWORDS) placeholder
      --   pattern = [[\b(KEYWORDS):]], -- ripgrep regex
      --   -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
      -- },
    },
  },

  {
    'folke/trouble.nvim',
    -- tag = 'v3.7.1',
    version = 'v3.x',
    cmd = 'Trouble',
    opts = {},
    -- event = 'CursorHold',
    keys = {
      { '<leader>x', '', desc = '+diagnostics/quickfix' },
      { '<leader>X', '<cmd>Trouble<cr>', desc = 'Trouble', mode = { 'n', 'v' } },
      { '<leader>xs', '<cmd>Trouble symbols toggle<cr>', desc = 'Symbols (Trouble)', mode = { 'n', 'v' } },
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
    init = function()
      -- -- Automatically open Trouble quickfix
      -- -- FIXME: No results for **qflist**
      -- vim.api.nvim_create_autocmd('QuickFixCmdPost', {
      --   callback = function()
      --     vim.cmd('Trouble qflist open')
      --   end,
      -- })
      -- vim.api.nvim_create_autocmd('DiagnosticChanged', {
      --   callback = function()
      --     if vim.diagnostic.get(0) and #vim.diagnostic.get(0) > 0 then
      --       vim.cmd('Trouble diagnostics open')
      --     end
      --   end,
      -- })
    end,
  },

  -- https://github.com/stevearc/aerial.nvim
  -- require('aerial').setup()
  {
    'hedyhli/outline.nvim',
    version = 'v1.x',
    cmd = { 'Outline', 'OutlineOpen' },
    keys = {
      { '<leader>cs', '<cmd>Outline<cr>', desc = 'Toggle Outline' },
    },
    opts = {},
    -- opts = function()
    --   local defaults = require('outline.config').defaults
    --   local opts = {
    --     symbols = {
    --       icons = {},
    --       filter = vim.deepcopy(LazyVim.config.kind_filter),
    --     },
    --     keymaps = {
    --       up_and_jump = '<up>',
    --       down_and_jump = '<down>',
    --     },
    --   }
    --
    --   for kind, symbol in pairs(defaults.symbols.icons) do
    --     opts.symbols.icons[kind] = {
    --       icon = LazyVim.config.icons.kinds[kind] or symbol.icon,
    --       hl = symbol.hl,
    --     }
    --   end
    --   return opts
    -- end,
  },
  -- {
  --   'folke/edgy.nvim',
  --   dependencies = { 'outline.nvim' },
  --   event = 'VeryLazy',
  --   opts = {},
  -- },
}
