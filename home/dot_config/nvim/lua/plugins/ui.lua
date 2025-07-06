local spinner = vim.g.config.signs.spinner
local spinner_len = #spinner

vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = vim.g.config.signs.error,
  [vim.diagnostic.severity.WARN] = '!',
  [vim.diagnostic.severity.INFO] = 'i',
  [vim.diagnostic.severity.HINT] = '?',
}

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
  virtual_text = {
    source = 'if_many',
    prefix = '●',
  },
})

local display_dir = vim.fn.getcwd() -- vim.fn.fnamemodify('.', ':~')
---@type snacks.Config.dashboard
local dashboard = {
  enabled = true,
  preset = { header = 'Neovim' },
  sections = {
    -- { section = 'header', padding = 1 },
    { section = 'startup', padding = 1 },
    {
      section = 'keys',
      padding = 1,
    },

    { title = 'Recent files', padding = 1 }, -- MRU
    { section = 'recent_files', limit = 8, padding = 1 },

    { title = 'Current directory ', file = display_dir, padding = 1 }, -- MRU
    { section = 'recent_files', cwd = true, limit = 8, padding = 1 },

    { title = 'Projects', padding = 1 },
    { section = 'projects', padding = 1 },

    { pane = 2, section = 'terminal', cmd = 'echo -n "$(hostname): $(date)"', height = 1, padding = 1 },
    -- { pane = 2, file = display_dir, padding = 1 },
    {
      pane = 2,
      desc = 'Startup time',
      icon = '⧗ ', -- ⧖
      -- padding = 1,
      key = 'S',
      action = function()
        vim.cmd('vertical StartupTime')
      end,
    },

    {
      pane = 2,
      icon = ' ',
      desc = 'Open directory ',
      file = display_dir,
      -- padding = 1,
      key = 'o',
      action = function()
        -- vim.cmd('silent !command -v open >/dev/null && open . || xdg-open .')
        if vim.fn.system('command -v open') ~= '' then
          vim.fn.system('open .')
        elseif vim.fn.system('command -v xdg-open') ~= '' then
          vim.fn.system('xdg-open .')
        else
          vim.notify('No command to open directory', vim.log.levels.ERROR)
        end
      end,
    },
    {
      pane = 2,
      icon = ' ',
      desc = 'Browse repository',
      -- padding = 1,
      key = 'b',
      action = function()
        Snacks.gitbrowse()
      end,
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
    },
    { pane = 2, title = ' ', padding = 0 },

    {
      pane = 2,
      icon = ' ',
      title = 'Git remote',
      section = 'terminal',
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = 'echo && git remote --verbose',
      height = 3,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },

    {
      pane = 2,
      icon = ' ',
      title = 'Git status',
      section = 'terminal',
      enabled = function()
        return Snacks.git.get_root() ~= nil
      end,
      cmd = 'echo && git status --short --branch --renames && echo && git --no-pager diff --stat -B -M -C',
      -- height = 28,
      padding = 1,
      ttl = 5 * 60,
      indent = 3,
    },

    -- { pane = 2, title = ' ', padding = 1 },

    --[[
    function()
      local in_git = Snacks.git.get_root() ~= nil
      -- stylua: ignore
      local cmds = {
        -- { cmd = 'git --no-pager diff --stat -B -M -C', height = 1 },
        { icon = ' ', title = 'Git diff', cmd = 'git --no-pager diff --stat -B -M -C', height = 10 },
        -- gh ext install meiji163/gh-notify
        { title = 'Notifications', cmd = 'gh notify -s -a -n1', action = function() vim.ui.open('https://github.com/notifications') end, key = 'n', icon = ' ', height = 3, enabled = true },
        { title = 'Open issues', cmd = 'gh issue list -L 3', key = 'i', action = function() vim.fn.jobstart('gh issue list --web', { detach = true }) end, icon = ' ', height = 3 },
        { icon = ' ', title = 'Open PRs', cmd = 'gh pr list -L 3', key = 'P', action = function() vim.fn.jobstart('gh pr list --web', { detach = true }) end, height = 3 },
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
    --]]
  },
}

-- local function lualine_winbar_filename()
--   return vim.fn.expand('%:t')
-- end

local function ghq_picker()
  local cmd = 'ghq list --full-path'
  local list = vim.fn.system(cmd)
  local results = vim.fn.split(list, '\n')
  local items = {}

  for _, ghqDir in ipairs(results) do
    table.insert(items, {
      text = ghqDir,
      file = ghqDir,
    })
  end

  ---@type snacks.picker.Config
  local opts = {
    title = cmd,
    items = items,
    cwd = vim.g.home,
    format = 'file',
    formatters = { file = { filename_only = false } },
    win = { preview = { minimal = true } },
  }
  Snacks.picker.pick(opts)
end

local function neovim_news()
  Snacks.win({
    file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
    width = 0.6,
    height = 0.6,
    wo = {
      spell = false,
      wrap = false,
      signcolumn = 'yes',
      statuscolumn = ' ',
      conceallevel = 3,
    },
  })
end

-- Terminal Mappings
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/util.lua
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and '<c-' .. dir .. '>' or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

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
    dependencies = { 'folke/snacks.nvim' },
    tag = 'v1.0.2',
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
        current_line_blame = false, -- Snacks.git.blame_line()
      }
    end,
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
          statusline = {
            'dbui',
            'snacks_dashboard',
            'snacks_layout_box',
            -- 'snacks_picker_list',
            -- 'trouble',
          },
          -- winbar = {},
        },
        always_divide_middle = true,
        always_show_tabline = false,
        globalstatus = false,
      },
      sections = {
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
            'overseer',
            label = '', -- Prefix for task counts
            colored = true, -- Color the task icons and counts
            symbols = {
              ['CANCELED'] = ' ',
              ['FAILURE'] = '󰅚 ',
              ['SUCCESS'] = '󰄴 ',
              ['RUNNING'] = '󰑮 ',
            },
            unique = false, -- Unique-ify non-running task count by name
            name = nil, -- List of task names to search for
            name_not = false, -- When true, invert the name search
            status = nil, -- List of task statuses to display
            status_not = false, -- When true, invert the status search
          },
          -- 'nvim_treesitter#statusline(90)',
          -- stylua: ignore
          {
            function() return '  ' .. require('dap').status() end,
            cond = function() return package.loaded.dap and require('dap').status() ~= '' end,
            color = function() return { fg = Snacks.util.color('Debug') } end,
          },
          -- stylua: ignore
          {
            require('lazy.status').updates,
            cond = require('lazy.status').has_updates,
            color = function() return { fg = Snacks.util.color('Special') } end,
          },
          {
            -- FIXME: lazy load
            'mcphub',
            cond = function()
              return package.loaded.mcphub and vim.bo.filetype == 'codecompanion'
            end,
          },
          {
            'codecompanion',
            cond = function()
              return vim.g.ai.codecompanion
            end,
            -- fmt = function(str)
            --   return str ~= '' and str or '{c}' -- 'CodeCompanion OFF'
            -- end,
          },
          {
            'codeium#GetStatusString',
            cond = function()
              return vim.g.ai.windsurf
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and str or '{w}' -- 'Windsurf OFF'
            -- end,
          },
          {
            'copilot',
            cond = function()
              return vim.g.ai.copilot_lua
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and str or '{}' -- 'Copilot OFF'
            -- end,
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
      },
      tabline = {
        -- lualine_a = { 'buffers' },
        -- lualine_b = { 'branch' },
        lualine_c = {
          'buffers',
          -- 'filename',
        },
        lualine_x = {
          function()
            -- if not package.loaded.persistence then
            --   return ''
            -- end
            -- FIXME: expensive call and flickers cursor
            -- local current = require('persistence').current()
            -- if not current then
            --   return ''
            -- end
            -- local parts = vim.fn.split(current, '/')
            -- local file = parts[#parts]:gsub('%%', '/')
            -- local path = file:sub(1, -5) -- Trim ".vim"
            local path = '.'
            return vim.fn.fnamemodify(path, ':~')
          end,
        },
        -- lualine_y = {},
        lualine_z = { 'tabs' },
      },
      -- winbar = {
      --   lualine_c = {
      --     -- 'filename',
      --     lualine_winbar_filename,
      --   },
      -- },
      -- inactive_winbar = {
      --   lualine_c = {
      --     -- 'filename',
      --     lualine_winbar_filename,
      --   },
      -- },

      -- https://github.com/nvim-lualine/lualine.nvim#available-extensions
      extensions = {
        'fugitive',
        'lazy',
        'mason',
        'nvim-dap-ui',
        'oil',
        'quickfix',
        'trouble',
      },
    },
    config = function(_, opts)
      -- FIXME: deep clone to not insert in inactive sections
      opts.inactive_sections = vim.tbl_deep_extend('keep', {
        lualine_b = { 'branch' },
      }, opts.sections)

      -- TODO: per buffer and show only on active
      -- local trouble = require('trouble')
      -- local symbols = trouble.statusline({
      --   mode = 'symbols',
      --   groups = {},
      --   title = false,
      --   filter = { range = true },
      --   format = '{kind_icon}{symbol.name:Normal}',
      --   hl_group = 'lualine_c_normal',
      -- })
      -- table.insert(opts.sections.lualine_c, {
      --   symbols and symbols.get,
      --   cond = function()
      --     return vim.b.trouble_lualine ~= false and symbols.has()
      --   end,
      -- })

      table.insert(opts.sections.lualine_x, 1, Snacks.profiler.status())

      local showtabline = vim.opt.showtabline
      require('lualine').setup(opts)
      vim.opt.showtabline = showtabline
    end,
  },

  {
    'folke/snacks.nvim',
    -- NOTE: snacks git utils not released yet
    -- branch = 'main',
    tag = 'v2.22.0',
    dependencies = {
      'echasnovski/mini.icons',
      -- {
      --   'nvim-tree/nvim-web-devicons',
      --   tag = 'v0.100',
      --   opts = {},
      -- },
      -- TODO: ensure tools are installed after startup
      -- 'WhoIsSethDaniel/mason-tool-installer.nvim',
    },
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      animate = { enabled = false },
      bigfile = { enabled = true },
      dashboard = dashboard,
      -- NOTE: hidden is false by default
      explorer = { enabled = true, replace_netrw = true },
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
      picker = {
        enabled = true,
        -- NOTE: maximize with meta-m
        -- https://github.com/LazyVim/LazyVim/discussions/5765
        -- https://github.com/folke/snacks.nvim/issues/1217#issuecomment-2661465574
        formatters = { file = { truncate = vim.o.columns <= 80 and 40 or 300 } },
      },
      quickfile = { enabled = true },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      terminal = {
        win = {
          keys = {
            nav_h = { '<C-h>', term_nav('h'), desc = 'Go to Left Window', expr = true, mode = 't' },
            nav_j = { '<C-j>', term_nav('j'), desc = 'Go to Lower Window', expr = true, mode = 't' },
            nav_k = { '<C-k>', term_nav('k'), desc = 'Go to Upper Window', expr = true, mode = 't' },
            nav_l = { '<C-l>', term_nav('l'), desc = 'Go to Right Window', expr = true, mode = 't' },
          },
        },
      },
      words = { enabled = true },
    },
    -- stylua: ignore
    keys = {
      -- { '<leader><space>', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
      { '<leader>\'', function() Snacks.picker.resume() end, desc = 'Resume last picker' },
      { '<leader>,', function() Snacks.picker.buffers() end, desc = 'Select buffer' },
      { '<leader>/', function() Snacks.picker.grep({ hidden = true }) end, desc = 'Grep' },
      { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command history' },

      -- Buffer
      { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Delete buffer' },
      { '<leader>br', function() Snacks.rename.rename_file() end, desc = 'Rename file' },

      -- Explore
      -- { '<leader>E', function() Snacks.explorer({ cwd = vim.fn.expand('%:p:h'), hidden = true }) end, desc = 'Explore current buffer\'s directory' },
      -- { '<leader>e', function() Snacks.explorer({ hidden = true }) end, desc = 'Explore root directory' },
      { '<leader>E', function() Snacks.picker.explorer({ cwd = vim.fn.expand('%:p:h'), hidden = true }) end, desc = 'Find in buffer directory' },
      { '<leader>e', function() Snacks.picker.explorer({ hidden = true }) end, desc = 'Find in root directory' }, -- Open file explorer in workspace root

      -- Find
      { '-', function() Snacks.picker.files({ cwd = vim.fn.expand('%:p:h'), hidden = true, }) end, desc = 'Find in buffer directory' },
      -- { '<leader>F', function() Snacks.picker.files({ cwd = vim.fn.getcwd(), hidden = true }) end, desc = 'Find in current directory' }, -- Open file explorer at current directory
      { '<leader>F', function() Snacks.picker.files({ cwd = vim.fn.expand('%:p:h'), hidden = true }) end, desc = 'Find in buffer directory' },
      { '<leader>f', function() Snacks.picker.files({ hidden = true }) end, desc = 'Find in root directory' }, -- Open file explorer in workspace root

      -- Git
      { '<leader>g', '', desc = '+git' },
      { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git branches' },
      { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git log' },
      { '<leader>gL', function() Snacks.picker.git_log_line() end, desc = 'Git log line' },
      { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git status' },
      { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git stash' },
      { '<leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git diff (hunks)' },
      { '<leader>gf', function() Snacks.picker.git_log_file() end, desc = 'Git log file' },

      { '<leader>gB', function() Snacks.gitbrowse() end, desc = 'Git browse', mode = { 'n', 'v' } },
      { '<leader>gG', function() Snacks.terminal({ 'gitui' }, { cwd = vim.fn.getcwd() }) end, desc = 'Open GitUI' },
      { '<leader>gL', function() Snacks.lazygit() end, desc = 'Open Lazygit' },

      -- Grep/search
      { '<leader>s', '', desc = '+search' }, -- grep/picker
      { '<leader>s\'', function() Snacks.picker.registers() end, desc = 'Registers' },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = 'Search history' },
      { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
      { '<leader>sb', function() Snacks.picker.grep_buffers() end, desc = 'Grep buffers' },
      { '<leader>s:', function() Snacks.picker.command_history() end, desc = 'Command history' },
      -- { '<leader>sC', function() Snacks.picker.files({ cwd = vim.fn.stdpath('config'), hidden = true }) end, desc = 'Find Config File' },
      { '<leader>sc', function() Snacks.picker.commands() end, desc = 'Commands' },
      { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, desc = 'Buffer diagnostics' },
      { '<leader>sG', ghq_picker, desc = 'Search git repostories (ghq)' },
      { '<leader>sg', function() Snacks.picker.git_files() end, desc = 'Find git files' },
      { '<leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
      { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help pages' },
      { '<leader>si', function() Snacks.picker.icons() end, desc = 'Icons' },
      { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
      { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
      { '<leader>sL', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
      { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
      { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
      { '<leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
      { '<leader>sP', function() Snacks.picker.lazy() end, desc = 'Search for Plugin Spec' },
      { '<leader>sp', function() Snacks.picker.projects() end, desc = 'Projects' },
      { '<leader>sq', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },
      { '<leader>sR', function() Snacks.picker.resume() end, desc = 'Resume last picker' },
      { '<leader>sr', function() Snacks.picker.recent() end, desc = 'Recent files' },
      { '<leader>ss', function() Snacks.picker.smart({ hidden = true }) end, desc = 'Smart find files' },
      { '<leader>su', function() Snacks.picker.undo() end, desc = 'Undo history' },
      { '<leader>sw', function() Snacks.picker.grep_word() end, desc = 'Visual selection or word', mode = { 'n', 'x' } },
      { '<leader>sz', function() Snacks.picker.zoxide() end, desc = 'Zoxide picker' },
      { '<leader>s.', function() Snacks.scratch.select() end, desc = 'Select scratch buffer' },

      -- LSP
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
      { 'gD', function() Snacks.picker.lsp_declarations() end, desc = 'Goto Declaration' },
      { 'gr', function() Snacks.picker.lsp_references() end, nowait = true, desc = 'References' },
      { 'gI', function() Snacks.picker.lsp_implementations() end, desc = 'Goto Implementation' },
      { 'gy', function() Snacks.picker.lsp_type_definitions() end, desc = 'Goto T[y]pe Definition' },
      { '<leader>l', '', desc = '+lsp' },
      { '<leader>lc', function() Snacks.picker.lsp_config() end, desc = 'Search LSP configurations' },
      { '<leader>ls', function() Snacks.picker.lsp_symbols() end, desc = 'LSP Symbols' },
      { '<leader>lS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'LSP Workspace Symbols' },

      { '<leader>T', '<cmd>Terminal<cr>', desc = 'Terminal' },

      { '<leader>n', function() Snacks.picker.notifications() end, desc = 'Notification picker' },
      { '<leader>N', function() Snacks.notifier.show_history() end, desc = 'Notification history' },

      { '<leader>u', '', desc = '+ui' },
      { '<leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
      { '<leader>uZ', function() Snacks.zen.zoom() end, desc = 'Toggle zoom' },
      { '<leader>uz', function() Snacks.zen() end, desc = 'Toggle zen mode' },
      { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle scratch buffer' },

      { '<c-/>',      function() Snacks.terminal() end, desc = 'Toggle Terminal' },
      { '<c-_>',      function() Snacks.terminal() end, desc = 'which_key_ignore' },
      { ']]',         function() Snacks.words.jump(vim.v.count1) end, desc = 'Next Reference', mode = { 'n', 't' } },
      { '[[',         function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference', mode = { 'n', 't' } },

      { '<backspace>o', '', desc = '+open' },
      { '<backspace>oD', '<cmd>Dashboard<cr>', desc = 'Dashboard' },
      { '<backspace>oN', '<cmd>NeovimNews<cr>', desc = 'Neovim News' },

      { '<leader>P', '', desc = '+profiler' },
      { '<leader>Ps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Bufer' },
    },
    -- config = function(_, opts)
    --   local snacks = require('snacks')
    --
    --   -- https://www.lazyvim.org/extras/util/chezmoi#snacksnvim-optional
    --   local chezmoi_entry = {
    --     icon = ' ',
    --     key = 'c',
    --     desc = 'Config',
    --     action = chezmoi_picker,
    --   }
    --   local config_index
    --   for i = #opts.dashboard.preset.keys, 1, -1 do
    --     if opts.dashboard.preset.keys[i].key == 'c' then
    --       table.remove(opts.dashboard.preset.keys, i)
    --       config_index = i
    --       break
    --     end
    --   end
    --   table.insert(opts.dashboard.preset.keys, config_index, chezmoi_entry)
    --
    --   snacks.setup(opts)
    -- end,
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

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
          -- tpope/vim-unimpaired
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

          -- Toggle the profiler
          Snacks.toggle.profiler():map('<leader>Pp')
          -- Toggle the profiler highlights
          Snacks.toggle.profiler_highlights():map('<leader>Ph')
        end,
      })

      -- Simple LSP progress
      -- vim.api.nvim_create_autocmd('LspProgress', {
      --   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      --   callback = function(ev)
      --     vim.notify(vim.lsp.status(), 'info', {
      --       id = 'lsp_progress',
      --       title = 'LSP Progress',
      --       opts = function(notif)
      --         notif.icon = ' '
      --           .. (
      --             ev.data.params.value.kind == 'end' and vim.g.config.signs.done
      --             or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % spinner_len + 1]
      --           )
      --       end,
      --     })
      --   end,
      -- })

      -- Advanced LSP progress
      -- ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
      -- local progress = vim.defaulttable()
      -- vim.api.nvim_create_autocmd('LspProgress', {
      --   ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
      --   callback = function(ev)
      --     local client = vim.lsp.get_client_by_id(ev.data.client_id)
      --     local value = ev.data.params.value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
      --     if not client or type(value) ~= 'table' then
      --       return
      --     end
      --     local p = progress[client.id]
      --
      --     for i = 1, #p + 1 do
      --       if i == #p + 1 or p[i].token == ev.data.params.token then
      --         p[i] = {
      --           token = ev.data.params.token,
      --           msg = ('[%3d%%] %s%s'):format(
      --             value.kind == 'end' and 100 or value.percentage or 100,
      --             value.title or '',
      --             value.message and (' **%s**'):format(value.message) or ''
      --           ),
      --           done = value.kind == 'end',
      --         }
      --         break
      --       end
      --     end
      --
      --     local msg = {} ---@type string[]
      --     progress[client.id] = vim.tbl_filter(function(v)
      --       return table.insert(msg, v.msg) or not v.done
      --     end, p)
      --
      --     local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
      --     vim.notify(table.concat(msg, '\n'), 'info', {
      --       id = 'lsp_progress',
      --       title = client.name,
      --       opts = function(notif)
      --         notif.icon = #progress[client.id] == 0 and ' '
      --           or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % spinner_len + 1]
      --       end,
      --     })
      --   end,
      -- })
      --
      -- -- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#oilnvim
      -- vim.api.nvim_create_autocmd('User', {
      --   pattern = 'OilActionsPost',
      --   callback = function(event)
      --     if event.data.actions.type == 'move' then
      --       Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
      --     end
      --   end,
      -- })

      -- Custom commands
      vim.api.nvim_create_user_command('Dashboard', function()
        Snacks.dashboard.open()
      end, { desc = 'Open dashboard (snacks)' })

      vim.api.nvim_create_user_command('Find', function()
        Snacks.picker.files({ cwd = vim.fn.expand('%:p:h'), hidden = true })
      end, { desc = 'Find files (snacks)' })

      vim.api.nvim_create_user_command('NeovimNews', neovim_news, { desc = 'Neovim news (snacks)' })

      vim.api.nvim_create_user_command('Terminal', function()
        Snacks.terminal()
      end, { desc = 'Toggle terminal (snacks)' })
    end,
  },

  {
    'folke/todo-comments.nvim',
    -- NOTE: snacks todo comments not released yet
    branch = 'main',
    -- tag = 'v1.4.0',
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
}
