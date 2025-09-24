-- local function lualine_winbar_filename()
--   return vim.fn.expand('%:t')
-- end

local overseer_status = {
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
}

local lazy_status = {
  require('lazy.status').updates,
  cond = require('lazy.status').has_updates,
  color = function()
    return { fg = Snacks and Snacks.util.color('Special') }
  end,
}

local dap_status = {
  function()
    return '  ' .. require('dap').status()
  end,
  cond = function()
    return Snacks and package.loaded.dap and require('dap').status() ~= ''
  end,
  color = function()
    return { fg = Snacks and Snacks.util.color('Debug') }
  end,
}

-- https://github.com/ravitemer/mcphub.nvim/blob/main/doc/extensions/lualine.md
local mcphub_status = {
  function()
    -- Check if MCPHub is loaded
    if not vim.g.loaded_mcphub then
      return '󰐻 -'
    end

    local count = vim.g.mcphub_servers_count or 0
    local status = vim.g.mcphub_status or 'stopped'
    local executing = vim.g.mcphub_executing

    -- Show "-" when stopped
    if status == 'stopped' then
      return '󰐻 -'
    end

    -- Show spinner when executing, starting, or restarting
    if executing or status == 'starting' or status == 'restarting' then
      local frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
      local frame = math.floor(vim.loop.now() / 100) % #frames + 1
      return '󰐻 ' .. frames[frame]
    end

    return '󰐻 ' .. count
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
    'nvim-lualine/lualine.nvim',
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
          -- 'nvim_treesitter#statusline(90)',
          dap_status,
          mcphub_status,
          {
            'codecompanion',
            cond = function()
              return vim.g.ai and vim.g.ai.codecompanion
            end,
            -- fmt = function(str)
            --   return str ~= '' and str or '{c}' -- 'CodeCompanion OFF'
            -- end,
          },
          {
            'codeium#GetStatusString',
            cond = function()
              return vim.g.ai and vim.g.ai.windsurf
            end,
            -- fmt = function(str)
            --   return str and str ~= '' and str or '{w}' -- 'Windsurf OFF'
            -- end,
          },
          {
            'copilot',
            cond = function()
              return vim.g.ai and vim.g.ai.copilot_lua
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
              error = vim.g.diagnostic_signs[vim.diagnostic.severity.ERROR] .. ' ',
              warn = vim.g.diagnostic_signs[vim.diagnostic.severity.WARN] .. ' ',
              info = vim.g.diagnostic_signs[vim.diagnostic.severity.INFO] .. ' ',
              hint = vim.g.diagnostic_signs[vim.diagnostic.severity.HINT] .. ' ',
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
          overseer_status,
          lazy_status,
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
            local path = vim.fn.fnamemodify('.', ':~')
            return (vim.g.config.node.version and 'nodejs v' .. vim.g.config.node.version .. ' ' or '') .. path
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

      if Snacks then
        table.insert(opts.sections.lualine_x, 1, Snacks.profiler.status())
      end

      local showtabline = vim.opt.showtabline
      require('lualine').setup(opts)
      vim.opt.showtabline = showtabline
    end,
  },
}
