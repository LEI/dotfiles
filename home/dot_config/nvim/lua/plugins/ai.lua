if not vim.g.features.ai then
  return {}
end

vim.g.ai = {
  avante = false,
  claude = false,
  codecompanion = true,
  copilot = false,
  copilot_lua = true,
  mcphub = true,
  windsurf = false,
}

local filetypes = {
  -- css = true, -- less, scss...
  dockerfile = true,
  go = true,
  hcl = true,
  html = true,
  javascript = true,
  lua = true,
  nginx = true,
  nu = true,
  php = true,
  python = true,
  ruby = true,
  rust = true,
  sh = function()
    return not string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*')
  end,
  sql = true,
  terraform = true,
  typescript = true,
  vim = true,

  -- yaml = false,
  -- markdown = false,
  -- help = false,
  -- gitcommit = false,
  -- gitrebase = false,
  -- hgcommit = false,
  -- svn = false,
  -- cvs = false,
  -- ['.'] = false,
  ['*'] = false,
}

vim.g.codeium_enabled = vim.g.ai.windsurf
-- vim.g.codeium_filetypes_disabled_by_default = true
-- vim.g.codeium_filetypes = filetypes

-- NOTE: replaced with copilot.lua
vim.g.copilot_enabled = vim.g.ai.copilot
-- vim.g.copilot_filetypes = filetypes

-- https://github.com/ravitemer/mcphub.nvim
-- https://ravitemer.github.io/mcphub.nvim/configuration.html

local node_prefix = vim.g.config.node.prefix or ''

return {
  {
    'ravitemer/mcphub.nvim',
    enabled = vim.g.ai.mcphub,
    -- tag = 'v6.2.0',
    version = 'v6.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- build = node_prefix .. 'npm' .. ' install --global mcp-hub@4.2.0',
    -- build = 'bundled_build.lua',
    cmd = 'MCPHub',
    keys = {
      { '<leader>H', '<cmd>MCPHub<cr>', desc = 'MCPHub', mode = { 'n', 'v' } },
    },
    opts = {
      auto_approve = false,
      auto_toggle_mcp_servers = true,

      use_bundled_binary = false,

      cmd = node_prefix .. 'node',
      cmdArgs = { node_prefix .. 'mcp-hub' },

      -- config = vim.fn.expand('~/.config/mcphub/servers.json'),
      -- port = 37373,
      -- server_url = 'http://localhost:37373',

      extensions = {
        avante = {
          make_slash_commands = true, -- make /slash commands from MCP server prompts
        },
      },
    },
    -- config = function(_, opts)
    --   require('mcphub').setup(opts)
    -- end,
  },

  {
    'yetone/avante.nvim',
    enabled = vim.g.ai.avante and vim.fn.has('nvim-0.10'),
    -- tag = 'v0.0.27',
    version = 'v0.0.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',

      'echasnovski/mini.icons', -- or nvim-tree/nvim-web-devicons
      'folke/snacks.nvim', -- for input provider snacks
      -- 'zbirenbaum/copilot.lua', -- for providers='copilot'
      'HakonHarnes/img-clip.nvim', -- for image pasting
      'MeanderingProgrammer/render-markdown.nvim',
    },
    build = function()
      if vim.fn.has('win32') == 1 then
        return 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
      else
        return 'make'
      end
    end,
    cmd = { 'Avante', 'AvanteChat', 'AvanteToggle' },
    keys = {
      {
        '<leader>A',
        '<cmd>AvanteToggle<cr>',
        desc = 'Avante',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      -- provider = 'claude',
      -- providers = {
      --   claude = {
      --     endpoint = 'https://api.anthropic.com',
      --     model = 'claude-sonnet-4-20250514',
      --     timeout = 30000, -- Timeout in milliseconds
      --     extra_request_body = {
      --       temperature = 0.75,
      --       max_tokens = 20480,
      --     },
      --   },
      -- },

      -- https://ravitemer.github.io/mcphub.nvim/extensions/avante.html
      -- system_prompt as function ensures LLM always has latest MCP server state
      -- This is evaluated for every message, even in existing chats
      system_prompt = vim.g.ai.mcphub and function()
        local hub = require('mcphub').get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ''
      end or nil,
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = vim.g.ai.mcphub and function()
        return {
          require('mcphub.extensions.avante').mcp_tool(),
        }
      end or nil,
    },
  },

  {
    'greggh/claude-code.nvim',
    enabled = vim.g.ai.claude,
    tag = 'v0.4.3',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'ClaudeCode', 'ClaudeCodeContinue', 'ClaudeCodeResume', 'ClaudeCodeVerbose' },
    keys = {
      { '<leader>cC', '<cmd>ClaudeCode<cr>', desc = 'Claude Code', mode = { 'n', 'v' } },
    },
    opts = {
      -- command = 'claude',
      -- keymaps = {
      --   toggle = {
      --     normal = '<C-,>', -- Normal mode keymap for toggling Claude Code, false to disable
      --     terminal = '<C-,>', -- Terminal mode keymap for toggling Claude Code, false to disable
      --     variants = {
      --       continue = '<leader>cC', -- Normal mode keymap for Claude Code with continue flag
      --       verbose = '<leader>cV', -- Normal mode keymap for Claude Code with verbose flag
      --     },
      --   },
      --   window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
      --   scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
      -- },
    },
  },
  {
    'olimorris/codecompanion.nvim',
    enabled = vim.g.ai.codecompanion,
    -- tag = 'v17.5.0',
    version = 'v17.x',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      -- 'echasnovski/mini.diff',
      'HakonHarnes/img-clip.nvim',
      -- https://codecompanion.olimorris.dev/installation.html#additional-plugins
      -- Alternative: https://github.com/OXY2DEV/markview.nvim
      'MeanderingProgrammer/render-markdown.nvim',
    },
    -- build = ':TSInstall markdown markdown_inline',
    cmd = { 'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanionCmd' },
    keys = {
      {
        '<leader>C',
        '<cmd>CodeCompanionChat Toggle<cr>',
        -- :CodeCompanion <prompt>
        desc = 'Code Companion Chat',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      -- https://ravitemer.github.io/mcphub.nvim/extensions/codecompanion.html
      extensions = vim.g.ai.mcphub
          and {
            mcphub = {
              callback = 'mcphub.extensions.codecompanion',
              opts = {
                show_result_in_chat = true, -- Show mcp tool results in chat
                make_vars = true, -- Convert resources to #variables
                make_slash_commands = true, -- Add prompts as /slash commands
              },
            },
          }
        or {},
      opts = {
        log_level = 'DEBUG', -- or 'TRACE'
      },
    },
  },

  {
    -- :Copilot setup
    'github/copilot.vim',
    enabled = vim.g.ai.copilot,
    -- tag = 'v1.50.0',
    version = 'v1.x',
  },

  {
    -- :Copilot auth
    'zbirenbaum/copilot.lua',
    enabled = vim.g.ai.copilot_lua,
    -- tag = '1.338.0',
    version = '1.x',
    dependencies = { 'AndreM222/copilot-lualine' },
    cmd = 'Copilot',
    -- event = 'InsertEnter',
    keys = {
      -- { '<leader>c', '', desc = '+copilot' },
      { '<leader>cp', '<cmd>Copilot panel<cr>', desc = 'Copilot panel', mode = { 'n', 'v' } },
      { '<leader>cs', '<cmd>Copilot status<cr>', desc = 'Copilot status' },
      { '<leader>cT', '<cmd>Copilot suggestion toggle_auto_trigger<cr>', desc = 'Copilot toggle auto-trigger' },
      { '<leader>ct', '<cmd>Copilot toggle<cr>', desc = 'Copilot toggle' },
    },
    init = function()
      local wk = require('which-key')
      wk.add({
        { '<leader>c', group = '+copilot' },
      })
    end,
    config = function()
      local copilot = require('copilot')
      copilot.setup({
        -- auth_provider_url = 'https://github.com',
        copilot_node_command = node_prefix .. 'node',
        -- workspace_folders = {
        --   vim.fn.expand('$HOME') .. '/src/*/*',
        -- },
        filetypes = filetypes,
        should_attach = function(_, bufname)
          -- vim.print('Should attach: ' .. bufname)
          if bufname == nil or bufname:match('.env') then
            return false
          end
          local basename = vim.fs.basename(bufname)
          return not (basename:match('.local') or basename:match('local.'))
        end,
        suggestion = {
          auto_trigger = false,
          keymap = {
            accept = '<M-l>',
            accept_word = false,
            accept_line = false,
            next = '<M-j>', -- '<M-]>',
            prev = '<M-k>', -- '<M-[>',
            dismiss = '<M-h>', -- '<C-]>',
          },
        },
      })
    end,
  },

  {
    -- :Codeium Auth
    'Exafunction/windsurf.vim',
    enabled = vim.g.ai.windsurf,
    cmd = { 'Codeium' },
    keys = {
      {
        '<leader>C',
        '<cmd>Codeium Chat<cr>',
        desc = 'Codeium Chat',
        mode = { 'n', 'v' },
      },
    },
    -- vim.g.codeium_disable_bindings = true
    -- vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    -- vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
    -- vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
    -- vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
  },

  -- Alternatives:
  -- https://github.com/A7Lavinraj/assistant.nvim
  -- https://github.com/CopilotC-Nvim/CopilotChat.nvim
  -- https://github.com/jackMort/ChatGPT.nvim
}
