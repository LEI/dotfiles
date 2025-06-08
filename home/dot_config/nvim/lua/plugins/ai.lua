vim.g.ai = {
  avante = false,
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

-- TODO: ensure node version is >=20 for copilot.lua
-- home .. '/.config/nvm/versions/node/v20.0.1/bin/node',
local node_prefix = vim.g.config.node.prefix or ''

return {
  {
    'ravitemer/mcphub.nvim',
    enabled = vim.g.ai.mcphub,
    tag = 'v5.11.0',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    build = node_prefix .. 'npm install --global mcp-hub@latest',
    -- build = 'bundled_build.lua',
    cmd = { 'MCPHub' },
    keys = {
      {
        '<leader>H',
        '<cmd>MCPHub<cr>',
        desc = 'MCPHub',
        mode = { 'n', 'v' },
      },
    },
    opts = {
      auto_approve = false,
      auto_toggle_mcp_servers = true,

      use_bundled_binary = false,

      cmd = node_prefix .. 'node',
      cmdArgs = { node_prefix .. 'mcp-hub' },

      -- TODO: install uv(x), setup EXA_API_KEY
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
    -- Requires nvim >= 0.10
    -- TODO: run make on install or update
    -- require('img-clip').setup()
    -- require('render-markdown').setup()
    'yetone/avante.nvim',
    enabled = vim.g.ai.avante,
    tag = 'v0.0.25',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
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
    'olimorris/codecompanion.nvim',
    enabled = vim.g.ai.codecompanion,
    tag = 'v17.5.0',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter',
        -- https://codecompanion.olimorris.dev/installation.html#additional-plugins
        -- Alternative: https://github.com/OXY2DEV/markview.nvim
        'MeanderingProgrammer/render-markdown.nvim',
        tag = 'v8.5.0',
        opts = {
          completions = { lsp = { enabled = true } },
          file_types = { 'markdown', 'codecompanion' },
          only_render_image_at_cursor = true,
          preset = 'none', -- none, obsidian, lazy
        },
      },
      -- https://github.com/echasnovski/mini.diff
      -- https://github.com/hakonharnes/img-clip.nvim
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
    tag = 'v1.50.0',
  },

  {
    -- :Copilot auth
    'zbirenbaum/copilot.lua',
    enabled = vim.g.ai.copilot_lua,
    -- tag = '1.338.0',
    dependencies = { 'AndreM222/copilot-lualine' },
    cmd = {
      'Copilot',
      -- 'CopilotToggle',
    },
    -- event = 'InsertEnter',
    keys = {
      -- { '<leader>ct', '<cmd>CopilotToggle<cr>', desc = 'Toggle Copilot suggestion auto-trigger', mode = { 'n', 'v' } },
    },
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
          return bufname ~= nil and not bufname:match('.env') and not bufname:match('.local')
        end,
        suggestion = {
          auto_trigger = true,
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
      -- vim.api.nvim_create_user_command('CopilotToggle', require('copilot.suggestion').toggle_auto_trigger, { desc = 'Toggle Copilot suggestion auto-trigger' })
    end,
  },

  {
    -- :Codeium Auth
    'Exafunction/windsurf.vim',
    enabled = vim.g.ai.windsurf,
    cmd = { 'Codeium' },
    keys = {
      {
        '<leader>cc',
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
