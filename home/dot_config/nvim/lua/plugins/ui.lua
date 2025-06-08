local spinner = vim.g.config.signs.spinner
local spinner_len = #spinner

vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = vim.g.config.signs.error,
  [vim.diagnostic.severity.WARN] = '!',
  [vim.diagnostic.severity.INFO] = 'i',
  [vim.diagnostic.severity.HINT] = '?',
}

vim.diagnostic.config({
  signs = {
    text = vim.g.diagnostic_signs,
    -- linehl = {
    --   [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
    -- },
    -- numhl = {
    --   [vim.diagnostic.severity.WARN] = 'WarningMsg',
    -- },
  },
})

local dashboard = {
  enabled = true,
  preset = { header = 'Neovim' },
  -- example = 'advanced',
  -- example = 'compact_files',
  sections = {
    -- { section = 'header', padding = 1 },
    { section = 'startup', padding = 1 },

    { section = 'keys', padding = 1 },

    { title = 'Recent files', padding = 1 }, -- MRU
    { section = 'recent_files', limit = 8, padding = 1 },

    { title = 'Projects', padding = 1 },
    { section = 'projects', padding = 1 },

    -- { pane = 2, section = 'terminal', cmd = 'echo -n "$(hostname): $(date)"', height = 2, padding = 1 },
    { pane = 2, file = vim.fn.fnamemodify('.', ':~'), padding = 1 },

    {
      pane = 2,
      icon = ' ',
      desc = 'Browse Repo',
      padding = 1,
      key = 'b',
      action = function()
        Snacks.gitbrowse()
      end,
    },
    {
      pane = 2,
      icon = ' ',
      -- title = 'Git Status',
      section = 'terminal',
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = 'git status --short --branch --renames',
      height = 8, -- 5,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },

    -- { pane = 2, title = 'MRU ', file = vim.fn.fnamemodify('.', ':~'), padding = 1 },
    { pane = 2, section = 'recent_files', cwd = true, limit = 8, padding = 1 },

    function()
      local in_git = Snacks.git.get_root() ~= nil
      local cmds = {
        {
          icon = ' ',
          -- title = 'Git Status',
          cmd = 'git --no-pager diff --stat -B -M -C',
          height = 10,
        },
        -- { title = 'Notifications', cmd = 'gh notify -s -a -n5', action = function() vim.ui.open('https://github.com/notifications') end, key = 'n', icon = ' ', height = 5, enabled = true },
        -- { title = 'Open Issues', cmd = 'gh issue list -L 3', key = 'i', action = function() vim.fn.jobstart('gh issue list --web', { detach = true }) end, icon = ' ', height = 7 },
        -- { icon = ' ', title = 'Open PRs', cmd = 'gh pr list -L 3', key = 'P', action = function() vim.fn.jobstart('gh pr list --web', { detach = true }) end, height = 7 },
      }
      return vim.tbl_map(function(cmd)
        return vim.tbl_extend('force', {
          pane = 2,
          section = 'terminal',
          enabled = in_git,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        }, cmd)
      end, cmds)
    end,
  },
}

local sections = {
  lualine_a = {
    {
      'mode',
      fmt = function(str)
        return str:sub(1, 3)
      end,
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
    function()
      if not package.loaded['package-info'] then
        return ''
      end
      return require('package-info').get_status()
    end,
    -- 'trouble',
    -- {
    --   troubleStatusline.get,
    --   -- cond = troubleStatusline.has,
    --   fmt = function(str)
    --     return '(' .. str .. ')'
    --   end,
    -- },
  },
  lualine_x = {
    {
      -- FIXME: lazy load
      'mcphub',
      -- cond = function()
      --   return vim.g.mcphub -- and not not package.loaded.mcphub
      -- end,
    },
    {
      'codecompanion',
      cond = function()
        return vim.g.ai.codecompanion
      end,
      fmt = function(str)
        return str ~= '' and str or '{c}' -- 'CodeCompanion OFF'
      end,
    },
    {
      'codeium#GetStatusString',
      cond = function()
        return vim.g.ai.windsurf
      end,
      fmt = function(str)
        return str and str ~= '' and str or '{w}' -- 'Windsurf OFF'
      end,
    },
    {
      'copilot',
      cond = function()
        return vim.g.ai.copilot_lua
      end,
      fmt = function(str)
        return str and str ~= '' and str or '{}' -- 'Copilot OFF'
      end,
    },
    'lsp-status',
    'nvim-lint',
    function()
      if not package.loaded.conform then
        return ''
      end
      local info = require('conform').list_formatters_to_run()
      local result = {}
      for index, item in pairs(info) do
        result[index] = item.name .. (item.available and ' ●' or ' ○') -- item.command
      end
      return table.concat(result, ' ')
    end,
    {
      'diagnostics',
      -- always_visible = true,
      symbols = {
        error = vim.g.diagnostic_signs[vim.diagnostic.severity.ERROR],
        warn = vim.g.diagnostic_signs[vim.diagnostic.severity.WARN],
        info = vim.g.diagnostic_signs[vim.diagnostic.severity.INFO],
        hint = vim.g.diagnostic_signs[vim.diagnostic.severity.HINT],
      },
    },
    'progress',
    'location',
    {
      'encoding',
      cond = function()
        return vim.o.encoding ~= 'utf-8'
      end,
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
}

-- https://github.com/stevearc/aerial.nvim
-- require('aerial').setup()

-- https://github.com/akinsho/bufferline.nvim
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
    tag = 'v1.1.1',
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
    tag = 'v1.0.2',
    cmd = 'Gitsigns',
    event = {
      -- 'CursorHold',
      'VeryLazy',
    },
    keys = {
      {
        ')h',
        '<cmd>Gitsigns next_hunk<cr>',
        desc = 'Next hunk',
        mode = { 'n', 'v' },
      },
      {
        '(h',
        '<cmd>Gitsigns prev_hunk<cr>',
        desc = 'Next hunk',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      current_line_blame = false,
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    -- enabled = false,
    event = 'VeryLazy',
    -- lazy = false,
    opts = {
      options = {
        icons_enabled = false,
        component_separators = '',
        section_separators = '',
        disabled_filetypes = {
          statusline = { 'snacks_dashboard' },
          winbar = { 'snacks_dashboard' },
        },
        always_divide_middle = false,
        always_show_tabline = false,
        globalstatus = true,
      },
      tabline = {
        -- lualine_a = { 'buffers' },
        -- lualine_b = { 'branch' },
        lualine_c = {
          'buffers',
          -- 'filename',
        },
        -- lualine_x = {},
        -- lualine_y = {},
        lualine_z = { 'tabs' },
      },
      winbar = { lualine_c = { 'filename' } },
      inactive_winbar = { lualine_c = { 'filename' } },

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
      },
    },
    config = function(_, opts)
      -- local trouble = require('trouble')
      -- local troubleStatusline = trouble.statusline({
      --   mode = 'lsp_document_symbols', -- 'diagnostics',
      --   groups = {},
      --   title = false,
      --   filter = { range = true },
      --   format = '{kind_icon}{symbol.name:Normal}',
      --   -- The following line is needed to fix the background color
      --   -- Set it to the lualine section you want to use
      --   hl_group = 'lualine_c_normal',
      -- })
      opts.sections = sections
      opts.inactive_sections = vim.tbl_deep_extend('keep', {
        lualine_b = { 'branch' },
      }, sections)
      require('lualine').setup(opts)
    end,
  },

  {
    'folke/snacks.nvim',
    tag = 'v2.22.0',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      animate = { enabled = false },
      bigfile = { enabled = true },
      dashboard = dashboard,
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = true },
      notifier = {
        enabled = true,
        level = vim.log.levels.TRACE,
        -- icons = {
        --   error = ' ',
        --   warn = ' ',
        --   info = ' ',
        --   debug = ' ',
        --   trace = ' ',
        -- },
        margin = { top = 0, right = 2, bottom = 2 },
        padding = true,
        style = 'minimal', -- compact, fancy, minimal
        timeout = 5000,
        top_down = false,
        refresh = 1000, -- Refresh at most every second (default: 50ms)
      },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      -- styles = {
      --   notification = {
      --     -- wo = { wrap = true } -- Wrap notifications
      --   },
      -- },
    },
    -- stylua: ignore
    keys = {
      -- Top Pickers & Explorer

      -- { '<leader><space>', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
      { '<leader>fs', function() Snacks.picker.smart({ hidden = true }) end, desc = 'Smart Find Files' },

      { '<leader>,', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>/', function() Snacks.picker.grep({ hidden = true }) end, desc = 'Grep' },
      { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },
      { '<leader>nn', function() Snacks.picker.notifications() end, desc = 'Notification picker' },

      -- { '<leader>e', function() Snacks.explorer() end, desc = 'File Explorer' },
      -- Open file explorer at current buffer's directory
      { '<leader>e', function() Snacks.picker.files({ cwd = vim.fn.expand('%:p:h') }) end, desc = 'File Explorer' },
      -- Open file explorer in workspace root
      { '<leader>E', function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end, desc = 'File Explorer (Workspace Root)' },

      -- find

      { '-', function() Snacks.picker.files({
        cwd = vim.fn.expand('%:p:h'),
        hidden = true,
      }) end, desc = 'Find in buffer directory' },

      { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>fc', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end, desc = 'Find Config File' },
      { '<leader>ff', function() Snacks.picker.files({hidden = true}) end, desc = 'Find Files' },
      { '<leader>fg', function() Snacks.picker.git_files() end, desc = 'Find Git Files' },
      { '<leader>fp', function() Snacks.picker.projects() end, desc = 'Projects' },
      { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent' },
      -- git
      { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },
      { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git Log' },
      { '<leader>gL', function() Snacks.picker.git_log_line() end, desc = 'Git Log Line' },
      { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
      { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git Stash' },
      { '<leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git Diff (Hunks)' },
      { '<leader>gf', function() Snacks.picker.git_log_file() end, desc = 'Git Log File' },
      -- Grep
      { '<leader>sb', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
      { '<leader>sB', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
      { '<leader>sg', function() Snacks.picker.grep() end, desc = 'Grep' },
      { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Visual selection or word', mode = { 'n', 'x' } },
      -- search
      { '<leader>s\'', function() Snacks.picker.registers() end, desc = 'Registers' },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = 'Search History' },
      { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
      { '<leader>sb', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
      { '<leader>sc', function() Snacks.picker.command_history() end, desc = 'Command History' },
      { '<leader>sC', function() Snacks.picker.commands() end, desc = 'Commands' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, desc = 'Buffer Diagnostics' },
      { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
      { '<leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
      { '<leader>si', function() Snacks.picker.icons() end, desc = 'Icons' },
      { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
      { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
      { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
      { '<leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
      { '<leader>sp', function() Snacks.picker.lazy() end, desc = 'Search for Plugin Spec' },
      { '<leader>sq', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },

      -- { '<leader>sR', function() Snacks.picker.resume() end, desc = 'Resume' },
      { '<leader>\'', function() Snacks.picker.resume() end, desc = 'Resume' },

      { '<leader>su', function() Snacks.picker.undo() end, desc = 'Undo History' },
      { '<leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
      -- LSP
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
      { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration' },
      { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
      { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
      { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition' },
      { '<leader>ss', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
      { '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },
      -- Other
      -- TODO: chezmoi, ghq
      { '<leader>z', function() Snacks.picker.zoxide() end, desc = 'Zoxide picker' },
      { '<leader>mz',  function() Snacks.zen() end, desc = 'Toggle Zen Mode' },
      { '<leader>Z',  function() Snacks.zen.zoom() end, desc = 'Toggle Zoom' },
      { '<leader>.',  function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
      { '<leader>S',  function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },

      {
        'T', -- '<leader>T',
        -- '<cmd>belowright split | resize 20 | terminal<cr>i',
        '<cmd>Terminal<cr>',
        desc = 'Terminal',
      },

      -- { '<leader>n',  function() Snacks.notifier.show_history() end, desc = 'Notification History' },
      { '<leader>N',  function() Snacks.notifier.show_history() end, desc = 'Notification history' },

      { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
      { '<leader>cR', function() Snacks.rename.rename_file() end, desc = 'Rename File' },
      { '<leader>gB', function() Snacks.gitbrowse() end, desc = 'Git Browse', mode = { 'n', 'v' } },
      { '<leader>gg', function() Snacks.lazygit() end, desc = 'Lazygit' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
      { '<c-/>',      function() Snacks.terminal() end, desc = 'Toggle Terminal' },
      { '<c-_>',      function() Snacks.terminal() end, desc = 'which_key_ignore' },
      { ']]',         function() Snacks.words.jump(vim.v.count1) end, desc = 'Next Reference', mode = { 'n', 't' } },
      { '[[',         function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference', mode = { 'n', 't' } },
      -- {
      --   '<leader>N',
      --   desc = 'Neovim News',
      --   function()
      --     Snacks.win({
      --       file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
      --       width = 0.6,
      --       height = 0.6,
      --       wo = {
      --         spell = false,
      --         wrap = false,
      --         signcolumn = 'yes',
      --         statuscolumn = ' ',
      --         conceallevel = 3,
      --       },
      --     })
      --   end,
      -- }
    },
    init = function()
      require('which-key').add({
        -- { '<leader>c', group = '' },
        { '<leader>f', group = 'find' },
        { '<leader>g', group = 'git' },
        { '<leader>l', group = 'lsp?' },
        { '<leader>p', group = 'package-info' },
        { '<leader>s', group = 'snacks' }, -- grep/find/picker/search
        { '<leader>u', group = 'toggle?' },
        { '<leader>x', group = 'trouble' },
        { 'g', group = 'goto' },
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
          Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
          Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
          Snacks.toggle.diagnostics():map('<leader>ud')
          Snacks.toggle.line_number():map('<leader>ul')
          Snacks.toggle
            .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map('<leader>uc')
          Snacks.toggle.treesitter():map('<leader>uT')
          Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>ub')
          Snacks.toggle.inlay_hints():map('<leader>uh')
          Snacks.toggle.indent():map('<leader>ug')
          Snacks.toggle.dim():map('<leader>uD')
        end,
      })

      -- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#oilnvim
      vim.api.nvim_create_autocmd('User', {
        pattern = 'OilActionsPost',
        callback = function(event)
          if event.data.actions.type == 'move' then
            Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
          end
        end,
      })

      vim.api.nvim_create_autocmd('LspProgress', {
        ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        callback = function(ev)
          vim.notify(vim.lsp.status(), 'info', {
            id = 'lsp_progress',
            title = 'LSP Progress',
            opts = function(notif)
              notif.icon = ' '
                .. (
                  ev.data.params.value.kind == 'end' and vim.g.config.signs.done
                  or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % spinner_len + 1]
                )
            end,
          })
        end,
      })

      vim.api.nvim_create_user_command('Dashboard', function()
        Snacks.dashboard.open()
      end, { desc = 'Open Snacks Dashboard' })

      vim.api.nvim_create_user_command('Terminal', function()
        Snacks.terminal()
      end, { desc = 'Toggle Snacks Terminal' })
    end,
  },

  {
    'folke/todo-comments.nvim',
    tag = 'v1.4.0',
    dependencies = {
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
      signs = true,
    },
  },

  {
    'folke/trouble.nvim',
    tag = 'v3.7.1',
    cmd = 'Trouble',
    opts = {},
    -- event = 'CursorHold',
    keys = {
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
        '<leader>cs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        -- FIXME: lsp-toggle
        '<leader>cl',
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
}
