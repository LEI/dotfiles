-- local function lualine_winbar_filename()
--   return vim.fn.expand('%:t')
-- end

local nodejs_status = {
  function()
    return 'v' .. vim.g.config.node.version
  end,
  cond = function()
    return vim.g.config.node.version and true or false
  end,
  icon = {
    vim.g.config.signs.nodejs,
    color = function()
      return { fg = Snacks and Snacks.util.color('String') }
    end,
  },
  -- padding = { left = 1, right = 0 },
}

local overseer_status = {
  'overseer',
  label = '', -- Prefix for task counts
  colored = true, -- Color the task icons and counts
  symbols = vim.g.config.signs.overseer_symbols or {},
  unique = false, -- Unique-ify non-running task count by name
  name = nil, -- List of task names to search for
  name_not = false, -- When true, invert the name search
  status = nil, -- List of task statuses to display
  status_not = false, -- When true, invert the status search
  -- padding = { left = 1, right = 0 },
}

local lazy_status = {
  require('lazy.status').updates,
  cond = require('lazy.status').has_updates,
  color = function()
    return { fg = Snacks and Snacks.util.color('Special') }
  end,
  -- padding = { left = 1, right = 0 },
}

local persistence_status = {
  function()
    -- local parts = vim.fn.split(current, '/')
    -- local file = parts[#parts]:gsub('%%', '/')
    -- local path = file:sub(1, -5) -- Trim ".vim"
    local path = vim.fn.fnamemodify('.', ':~')
    -- local icon = vim.g.current_session and vim.g.config.signs.persistence
    --   or vim.g.config.signs.persistence_off
    -- return icon .. ' ' .. path
    return path
  end,
  cond = function()
    return package.loaded.persistence and true or false
  end,
  icon = {
    vim.g.config.signs.persistence,
    -- align = 'right',
    color = function()
      return vim.g.current_session and { fg = Snacks and Snacks.util.color('WarningMsg') } or nil
    end,
  },
  -- padding = { left = 0, right = 1 },
}

local dap_status = {
  function()
    return require('dap').status()
  end,
  cond = function()
    return package.loaded.dap and require('dap').status() ~= ''
  end,
  color = function()
    return { fg = Snacks and Snacks.util.color('Debug') }
  end,
  icon = vim.g.config.signs.dap,
}

-- https://github.com/ravitemer/mcphub.nvim/blob/main/doc/extensions/lualine.md
local mcphub_status = {
  function()
    local frames = vim.g.config.signs.spinner
    local icon = vim.g.config.signs.mcp

    -- Check if MCPHub is loaded
    if not vim.g.loaded_mcphub then
      return icon .. ' -'
    end

    local count = vim.g.mcphub_servers_count or 0
    local status = vim.g.mcphub_status or 'stopped'
    local executing = vim.g.mcphub_executing

    -- Show "-" when stopped
    if status == 'stopped' then
      return icon .. '-'
    end

    -- Show spinner when executing, starting, or restarting
    if executing or status == 'starting' or status == 'restarting' then
      local now = (vim.uv or vim.loop).now
      local frame = math.floor(now() / 100) % #frames + 1
      return icon .. frames[frame]
    end

    return icon .. count
  end,
  color = function()
    if not vim.g.loaded_mcphub then
      return { fg = '#6c7086' } -- Gray for not loaded
    end

    local status = vim.g.mcphub_status or 'stopped'
    if status == 'ready' or status == 'restarted' then
      return { fg = '#50fa7b' } -- Green for connected
    elseif status == 'starting' or status == 'restarting' then
      return { fg = '#ffb86c' } -- Orange for connecting
    else
      return { fg = '#ff5555' } -- Red for error/stopped
    end
  end,
  cond = function()
    return package.loaded.mcphub and vim.bo.filetype == 'codecompanion'
  end,
}

-- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/extensions/oil.lua
local oil_extension = {
  sections = {
    lualine_c = {
      function()
        local ok, oil = pcall(require, 'oil')
        if not ok then
          return ''
        end
        local dir = oil.get_current_dir()
        if not dir then
          return ''
        end
        return vim.fn.fnamemodify(dir, ':~:.')
      end,
    },
  },
  filetypes = { 'oil' },
}

return {
  {
    -- 'nvim-lualine/lualine.nvim',
    'LEI/lualine.nvim',
    branch = 'fix/lsp-progress',
    event = 'VeryLazy',
    -- lazy = false,
    opts = {
      options = {
        icons_enabled = vim.g.config.icons_enabled,
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
        globalstatus = true,
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
            -- FIXME: icon visible on non active buffer, after snacks term open
            icon = '', -- vim.g.config.signs.branch,
            icons_enabled = false,
          },
          {
            'diff',
            -- colored = false,
            padding = { left = 0, right = 1 },
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
          -- 'nvim_treesitter#statusline(90)',
          dap_status,
          mcphub_status,
          {
            'codecompanion',
            cond = function()
              return vim.g.ai and vim.g.ai.codecompanion
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and 'cc[' .. str .. ']' or '{c}' -- 'CodeCompanion OFF'
            -- end,
            -- padding = { left = 1, right = 0 },
          },
          {
            'codeium#GetStatusString',
            cond = function()
              return vim.g.ai and vim.g.ai.windsurf
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and 'ws[' .. str .. ']' or '{w}' -- 'Windsurf OFF'
            -- end,
            -- padding = { left = 1, right = 0 },
          },
          {
            'copilot',
            cond = function()
              return vim.g.ai and vim.g.ai.copilot_lua
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and 'copilot[' .. str .. ']' or '{}' -- 'Copilot OFF'
            -- end,
            -- padding = { left = 1, right = 0 },
            on_click = function(_, button)
              if button == 'r' then
                vim.cmd('Copilot panel')
                return
              end
              vim.cmd('Copilot status')
            end,
          },
          {
            -- FIXME: icon and indicator only visible on non active buffer
            -- or not at all if globalstatus is true
            'lsp_status', -- 'lsp-status',
            icon = vim.g.config.signs.lsp, -- f013
            symbols = {
              spinner = vim.g.config.signs.spinner,
              done = vim.g.config.signs.done, -- '✓',
              separator = ' ',
            },
            -- List of LSP names to ignore (e.g., `null-ls`):
            ignore_lsp = {},
            -- Display the LSP name
            show_name = true,
            -- fmt = function(str)
            --   return str and str ~= '' and 'lsp[' .. str .. ']' or ''
            -- end,
            -- padding = { left = 1, right = 0 },
            padding = 0,
            on_click = function()
              vim.cmd('LspInfo')
            end,
          },
          {
            'nvim-lint',
            cond = function()
              return package.loaded.lint
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and 'lint[' .. str .. ']' or ''
            -- end,
            -- padding = { left = 1, right = 0 },
            on_click = function()
              vim.cmd('LintInfo')
            end,
          },
          {
            function()
              if not package.loaded.conform then
                return ''
              end
              local info = require('conform').list_formatters_to_run()
              local result = {}
              for index, item in pairs(info) do
                local sign = item.available and vim.g.config.signs.on or vim.g.config.signs.off
                result[index] = sign .. ' ' .. item.name -- item.command
              end
              return table.concat(result, ' ')
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and 'fmt[' .. str .. ']' or ''
            -- end,
            -- padding = { left = 1, right = 0 },
            on_click = function()
              vim.cmd('ConformInfo')
            end,
          },
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
            symbols = vim.g.config.signs.lualine_fileformat_symbols,
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
          nodejs_status,
          overseer_status,
          lazy_status,
          persistence_status,
        },
        lualine_y = {},
        lualine_z = {
          {
            'tabs',
            -- mode = 2,
            -- path = 1,
            show_modified_status = false,
          },
        },
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
        'avante',
        'fugitive',
        'lazy',
        'man',
        'mason',
        'nvim-dap-ui',
        oil_extension, -- 'oil',
        -- 'overseer',
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

      -- https://github.com/folke/sidekick.nvim#-statusline-integration
      if vim.g.ai and vim.g.ai.sidekick then
        -- -- Copilot status
        -- table.insert(opts.sections.lualine_c, {
        --   function()
        --     return ' '
        --   end,
        --   color = function()
        --     local status = require('sidekick.status').get()
        --     if status then
        --       return status.kind == 'Error' and 'DiagnosticError' or status.busy and 'DiagnosticWarn' or 'Special'
        --     end
        --   end,
        --   cond = function()
        --     local status = require('sidekick.status')
        --     return status.get() ~= nil
        --   end,
        -- })
        --
        -- -- CLI session status
        -- table.insert(opts.sections.lualine_x, 2, {
        --   function()
        --     local status = require('sidekick.status').cli()
        --     return ' ' .. (#status > 1 and #status or '')
        --   end,
        --   cond = function()
        --     return #require('sidekick.status').cli() > 0
        --   end,
        --   color = function()
        --     return 'Special'
        --   end,
        -- })
        local icons = {
          Error = { ' ', 'DiagnosticError' },
          Inactive = { ' ', 'MsgArea' },
          Warning = { ' ', 'DiagnosticWarn' },
          -- Normal = { LazyVim.config.icons.kinds.Copilot, 'Special' },
          Normal = { ' ', 'Special' },
        }
        table.insert(opts.sections.lualine_x, 2, {
          function()
            local status = require('sidekick.status').get()
            return status and vim.tbl_get(icons, status.kind, 1)
          end,
          cond = function()
            return require('sidekick.status').get() ~= nil
          end,
          color = function()
            local status = require('sidekick.status').get()
            local hl = status and (status.busy and 'DiagnosticWarn' or vim.tbl_get(icons, status.kind, 2))
            return { fg = Snacks.util.color(hl) }
          end,
          padding = 0,
        })

        table.insert(opts.sections.lualine_x, 2, {
          function()
            local status = require('sidekick.status').cli()
            return ' ' .. (#status > 1 and #status or '')
          end,
          cond = function()
            return #require('sidekick.status').cli() > 0
          end,
          color = function()
            return { fg = Snacks.util.color('Special') }
          end,
          padding = 0,
        })
      end

      if Snacks then
        table.insert(opts.sections.lualine_x, 1, Snacks.profiler.status())
      end

      local showtabline = vim.opt.showtabline
      require('lualine').setup(opts)
      vim.opt.showtabline = showtabline
    end,
  },
}
