local display_dir = vim.fn.getcwd() -- vim.fn.fnamemodify('.', ':~')
---@type snacks.Config.dashboard
local dashboard_sections = {
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
    icon = vim.g.config.signs.time,
    -- padding = 1,
    key = 'S',
    action = function()
      vim.cmd('vertical StartupTime')
    end,
  },

  {
    pane = 2,
    icon = vim.g.config.signs.open_directory,
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
    icon = vim.g.config.signs.git_browse,
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

  -- FIXME(neovide): fatal: not a git repository (exit code 128)
  {
    pane = 2,
    icon = vim.g.config.signs.git_remote,
    title = 'Git remote',
    section = 'terminal',
    enabled = function()
      return (not vim.g.neovide) and Snacks.git.get_root() ~= nil
    end,
    cmd = 'echo && git remote --verbose',
    height = 3,
    padding = 1,
    ttl = 5 * 60,
    indent = 3,
  },
  {
    pane = 2,
    icon = vim.g.config.signs.git_status,
    title = 'Git status',
    section = 'terminal',
    enabled = function()
      return (not vim.g.neovide) and Snacks.git.get_root() ~= nil
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
  -- { pane = 2, section = 'terminal', cmd = 'curl -s https://wttr.in/?0A' },
}

-- local function save_repeat()
--   return vim.fn.getreg('.'), vim.fn.getregtype('.')
-- end
--
-- local function restore_repeat(text, regtype)
--   vim.print('Restore repeat (TODO)', text, regtype)
--   -- FIXME: Invalid register value: '.'
--   -- vim.fn.setreg('.', text, regtype)
--   -- pcall(vim.fn.setreg, '.', text, regtype)
-- end

-- TODO: exclude from history (dot repeat)
local function grep_picker()
  local id = 1
  local ns_id = vim.api.nvim_create_namespace('grep')
  local original = vim.fn.getreg('/')
  -- local regtext, regtype = save_repeat()
  -- vim.print('Save repeat', regtext, regtype)
  local regex = true
  local search = original
  if vim.startswith(search, '\\V') then
    search = search:gsub('^\\V', '')
    if regex then
      search = search:gsub('([%^$~+.*%[%]{}()|])', '\\%1')
    else
      search = search:gsub('\\\\', '\\')
    end
    search = search:gsub('^ ', '\\s'):gsub(' $', '\\s')
  else
    -- regex = true
    -- search = search:gsub('^\\<(.*)\\>$', '\\<%1\\>')
    search = search:gsub('^\\<(.*)\\>$', '%1')
  end
  local function set_virtual_text(text)
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_extmark(0, ns_id, line - 1, col, {
      id = id,
      end_line = 0,
      virt_text = { { text, 'Comment' } },
      virt_text_pos = 'overlay',
    })
  end
  local function del_virtual_text()
    -- vim.api.nvim_buf_del_extmark(0, ns_id, id)
    pcall(vim.api.nvim_buf_del_extmark, 0, ns_id, id)
  end
  Snacks.picker.grep({
    hidden = true,
    limit = 100,
    need_search = true,
    regex = regex,
    -- search = search,
    actions = {
      insert_enter = function(picker)
        if picker.input.filter.search == '' and search then
          del_virtual_text()
          -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          -- vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { search })
          vim.api.nvim_paste(search, false, 0)
        else
          picker:action('confirm')
          picker:close()
          -- TODO: update search register vim.cmd('normal! /' .. original)
        end
      end,
    },
    win = {
      input = {
        keys = {
          -- ['<c-c>'] = { 'close', mode = { 'n', 'i' } },
          ['<cr>'] = { 'insert_enter', mode = { 'i' } },
        },
      },
    },
    on_change = function(picker)
      vim.schedule(function()
        if picker.input.filter.search == '' and search then
          set_virtual_text(search)
        elseif picker.input.filter.search ~= '' and search then
          del_virtual_text()
        end
      end)
    end,
    on_show = function(picker)
      vim.schedule(function()
        if picker.input.filter.search == '' and search then
          set_virtual_text(search)
        end
      end)
    end,
    on_close = function()
      del_virtual_text()
      -- restore_repeat(regtext, regtype)
    end,
  })
end

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
    cwd = vim.env.HOME,
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

return {
  -- https://www.lazyvim.org/extras/editor/snacks_picker
  {
    'folke/snacks.nvim',
    -- branch = 'main',
    version = 'v2.x',
    dependencies = {
      'nvim-mini/mini.icons',
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
      dashboard = {
        enabled = true,
        preset = { header = 'Neovim' },
        sections = dashboard_sections,
      },
      explorer = {
        enabled = vim.g.config.explorer == 'snacks',
        replace_netrw = false, -- true,
      },
      indent = { enabled = false },
      input = { enabled = true },
      notifier = {
        enabled = true,

        -- FIXME: width = { min = 40, max = 0.4 },
        -- height = { min = 1, max = 0.6 },
        -- editor margin to keep free. tabline and statusline are taken into account automatically
        margin = { top = 0, right = 1, bottom = vim.o.cmdheight },
        padding = true,

        level = vim.log.levels.TRACE,
        icons = {
          error = vim.g.config.signs.error,
          warn = vim.g.config.signs.warn,
          info = vim.g.config.signs.info,
          debug = vim.g.config.signs.debug,
          trace = vim.g.config.signs.trace,
        },
        -- keep = function(notif)
        --   return vim.fn.getcmdpos() > 0
        -- end,

        -- sort = { 'level', 'added' }, -- sort by level and time
        sort = { 'added' },
        ---@type snacks.notifier.style
        -- style = 'minimal', -- compact, fancy, minimal
        style = function(buf, notif, ctx)
          -- https://github.com/folke/snacks.nvim/blob/v2.23.0/lua/snacks/notifier.lua#L176
          ctx.opts.border = vim.g.config.border or 'none'
          local whl = ctx.opts.wo.winhighlight
          ctx.opts.wo.winhighlight = whl:gsub(ctx.hl.msg, 'SnacksNotifierMinimal')
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, '\n'))
          vim.api.nvim_buf_set_extmark(buf, ctx.ns, 0, 0, {
            virt_text = { { notif.icon .. ' ', ctx.hl.icon } },
            virt_text_pos = 'inline', -- 'right_align',
          })
        end,
        -- top_down = false,

        -- date_format = '%R', -- time format for notifications
        -- format for footer when more lines are available
        -- `%d` is replaced with the number of lines.
        -- only works for styles with a border
        ---@type string|boolean
        -- more_format = ' ↓ %d lines ',

        refresh = 1000, -- Refresh at most every second (default: 50ms)
        timeout = 5000, -- Default: 3000ms
      },
      picker = {
        enabled = true,

        -- Always open in current buffer
        -- https://github.com/folke/snacks.nvim/issues/1984
        main = { file = false },

        prompt = vim.g.config.signs.snacks_picker_prompt,
        icons = vim.g.config.signs.snacks_picker_icons,

        -- NOTE: maximize with meta-m
        -- https://github.com/LazyVim/LazyVim/discussions/5765
        -- https://github.com/folke/snacks.nvim/issues/1217#issuecomment-2661465574
        formatters = { file = { truncate = vim.o.columns <= 80 and 40 or 300 } },

        sources = {
          lines = {
            confirm = function(picker, ...)
              local search = picker.input:get()
              vim.print(search)
              Snacks.picker.actions.confirm(picker, ...)
            end,
          },
        },

        actions = {
          flash = function(picker)
            require('flash').jump({
              pattern = '^',
              label = { after = { 0, 0 } },
              search = {
                mode = 'search',
                exclude = {
                  function(win)
                    return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'snacks_picker_list'
                  end,
                },
              },
              action = function(match)
                local idx = picker.list:row2idx(match.pos[1])
                picker.list:_move(idx, true, true)
              end,
            })
          end,

          -- TODO: if vim.g.ai and vim.g.ai.sidekick
          sidekick_send = function(...)
            return require('sidekick.cli.picker.snacks').send(...)
          end,

          -- ---@param p snacks.Picker
          -- toggle_cwd = function(p)
          --   local root = LazyVim.root({ buf = p.input.filter.current_buf, normalize = true })
          --   local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or '.')
          --   local current = p:cwd()
          --   p:set_cwd(current == root and cwd or root)
          --   p:find()
          -- end,
          -- require("trouble.sources.snacks").actions,
          trouble_open = function(...)
            return require('trouble.sources.snacks').actions.trouble_open.action(...)
          end,
        },
        win = {
          input = {
            keys = {
              ['<a-a>'] = { 'sidekick_send', mode = { 'n', 'i' } },
              ['<a-s>'] = { 'flash', mode = { 'n', 'i' } },
              -- ['<a-c>'] = { 'toggle_cwd', mode = { 'n', 'i' } },
              ['<c-t>'] = { 'trouble_open', mode = { 'n', 'i' } },
            },
          },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      styles = {
        -- notifier = {
        --   gap = 1,
        -- },
        -- terminal = {
        --   -- FIXME: prsist terminal buffers created with Snacks
        --   bo = {
        --     buflisted = true,
        --     filetype = 'snacks_terminal',
        --   },
        -- },
      },
      terminal = {
        -- interactive = false,
        win = {
          keys = {
            nav_h = { '<C-h>', term_nav('h'), desc = 'Go to Left Window', expr = true, mode = 't' },
            nav_j = { '<C-j>', term_nav('j'), desc = 'Go to Lower Window', expr = true, mode = 't' },
            nav_k = { '<C-k>', term_nav('k'), desc = 'Go to Upper Window', expr = true, mode = 't' },
            nav_l = { '<C-l>', term_nav('l'), desc = 'Go to Right Window', expr = true, mode = 't' },
          },
          -- position = 'top', -- bottom
          style = 'minimal', -- Default 'terminal' includes a title bar
        },
        -- shell = 'nu', -- vim.o.shell
      },
      words = { enabled = true },
    },
    -- stylua: ignore
    keys = {
      -- { '<leader><space>', function() Snacks.picker.smart() end, desc = 'Smart Find Files' },
      { '<leader>\'', function() Snacks.picker.resume() end, desc = 'Resume last picker' },
      { '<leader>,', function() Snacks.picker.buffers() end, desc = 'Select buffer' },
      { '<leader>/', grep_picker, desc = 'Grep picker' },
      { '<leader>\\', function() Snacks.picker.grep({ hidden = true, }) end, desc = 'Grep' },
      { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command history' },

      -- Buffer
      { '<leader>bd', function() Snacks.bufdelete() end, desc = 'Delete buffer' },
      { '<leader>bo', function() Snacks.bufdelete.other() end, desc = 'Delete other buffers' },
      { '<leader>br', function() Snacks.rename.rename_file() end, desc = 'Rename file' },

      -- Explore
      { '<leader>E', function()
        local cwd = vim.fn.expand('%:p:h'):gsub('^oil://', '')
        Snacks.explorer({ cwd = cwd, hidden = true })
      end, desc = 'Find in buffer directory' },
      { '<leader>e', function() Snacks.explorer({ hidden = true }) end, desc = 'Find in root directory' }, -- Open file explorer in workspace root

      -- Find
      -- { '-', function() Snacks.picker.files({ cwd = vim.fn.expand('%:p:h'), hidden = true }) end, desc = 'Find in buffer directory' },
      -- { '<leader>F', function() Snacks.picker.files({ cwd = vim.fn.getcwd(), hidden = true }) end, desc = 'Find in current directory' }, -- Open file explorer at current directory
      -- NOTE: does not open in current buffer for some filetypes (help, oil...)
      { '<leader>F', function()
        local cwd = vim.fn.expand('%:p:h'):gsub('^oil://', '')
        Snacks.picker.files({
          cwd = cwd,
          hidden = true,
          title = 'Files in ' .. vim.fn.fnamemodify(cwd, ':~:.'),
        })
      end, desc = 'Find in buffer directory' },
      { '<leader>f', function() Snacks.picker.files({ hidden = true }) end, desc = 'Find in root directory' }, -- Open file explorer in workspace root

      -- Git
      { '<leader>g', '', desc = '+git' },
      { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git branches' },
      { '<leader>gl', function() Snacks.picker.git_log() end, desc = 'Git log' },
      { '<leader>gL', function() Snacks.picker.git_log_line() end, desc = 'Git log line' },
      { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git status' },
      { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git stash' },
      { '<leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git diff (hunks)' },
      { '<leader>gD', function() Snacks.picker.git_diff({ base = "origin" }) end, desc = 'Git diff (origin)' },
      { '<leader>gf', function() Snacks.picker.git_log_file() end, desc = 'Git log file' },

      { '<leader>gB', function() Snacks.gitbrowse() end, desc = 'Git browse', mode = { 'n', 'v' } },
      { '<leader>gG', function() Snacks.terminal({ 'gitui' }, { cwd = vim.fn.getcwd() }) end, desc = 'Open GitUI' },

      -- FIXME: C-{j,k}
      { '<leader>gL', function() Snacks.lazygit() end, desc = 'Open Lazygit' },
      -- { '<leader>gg', function() Snacks.lazygit( { cwd = LazyVim.root.git() }) end, { desc = 'Lazygit (Root Dir)' } },
      -- { '<leader>gG', function() Snacks.lazygit() end, { desc = 'Lazygit (cwd)' } },
      -- { '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Current File History' } },
      -- { '<leader>gl', function() Snacks.picker.git_log({ cwd = LazyVim.root.git() }) end, { desc = 'Git Log' } },
      -- { '<leader>gL', function() Snacks.picker.git_log() end, { desc = 'Git Log (cwd)' } },

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

      -- { '<leader>"', '<cmd>horizontal terminal<cr>', desc = 'Open terminal' },
      -- { '<leader>%', '<cmd>vertical terminal<cr>', desc = 'Open terminal' },
      { '<leader>"', '<cmd>TerminalOpen<cr>', desc = 'Open terminal (snacks)' },
      { '<leader>%', '<cmd>TerminalOpen<cr>', desc = 'Open terminal (snacks)' },

      { '<leader>n', function() Snacks.picker.notifications() end, desc = 'Notification picker' },
      { '<leader>N', function() Snacks.notifier.show_history() end, desc = 'Notification history' },

      { '<leader>u', '', desc = '+ui' },
      { '<leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
      { '<leader>uZ', function() Snacks.zen.zoom() end, desc = 'Toggle zoom' },
      { '<leader>uz', function() Snacks.zen() end, desc = 'Toggle zen mode' },
      { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle scratch buffer' },

      -- { '<c-/>',      function() Snacks.terminal() end, desc = 'Toggle Terminal' },
      -- { '<c-_>',      function() Snacks.terminal() end, desc = 'which_key_ignore' },
      { ']]',         function() Snacks.words.jump(vim.v.count1) end, desc = 'Next Reference', mode = { 'n', 't' } },
      { '[[',         function() Snacks.words.jump(-vim.v.count1) end, desc = 'Prev Reference', mode = { 'n', 't' } },

      { '<backspace>o', '', desc = '+open' },
      { '<backspace>oD', '<cmd>Dashboard<cr>', desc = 'Dashboard' },
      { '<backspace>oN', '<cmd>NeovimNews<cr>', desc = 'Neovim News' },

      { '<backspace>p', '', desc = '+profiler' },
      { '<backspace>ps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Bufer' },
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
          Snacks.toggle.profiler():map('<backspace>pp')
          -- Toggle the profiler highlights
          Snacks.toggle.profiler_highlights():map('<backspace>ph')

          if vim.g.ai and vim.g.ai.sidekick then
            Snacks.toggle({
              name = 'Sidekick NES',
              get = function()
                return require('sidekick.nes').enabled
              end,
              set = function(state)
                require('sidekick.nes').enable(state)
              end,
            }):map('<leader>uN')
          end
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

      vim.api.nvim_create_user_command('Colorize', function()
        Snacks.terminal.colorize()
      end, { desc = 'Colorize terminal (snacks)' })

      vim.api.nvim_create_user_command('Dashboard', function()
        Snacks.dashboard.open()
      end, { desc = 'Open dashboard (snacks)' })
      vim.api.nvim_create_user_command('NeovimNews', neovim_news, { desc = 'Neovim news (snacks)' })

      vim.api.nvim_create_user_command('Find', function()
        local cwd = vim.fn.expand('%:p:h'):gsub('^oil://', '')
        Snacks.picker.files({ cwd = cwd, hidden = true })
      end, { desc = 'Find files (snacks)' })

      vim.api.nvim_create_user_command('TerminalList', function()
        local list = Snacks.terminal.list()
        dd(list)
      end, { desc = 'Terminal list (snacks)' })
      vim.api.nvim_create_user_command('TerminalOpen', function()
        Snacks.terminal.open()
      end, { desc = 'Open terminal (snacks)' })
      vim.api.nvim_create_user_command('TerminalToggle', function()
        Snacks.terminal.toggle()
      end, { desc = 'Toggle terminal (snacks)' })
    end,
  },
}
