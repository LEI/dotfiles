if not vim.g.features.ai then
  return {}
end

vim.g.ai = {
  avante = false,
  claude = true,
  codecompanion = true,
  copilot = false,
  copilot_lua = true,
  mcphub = true,
  sidekick = true,
  windsurf = false,
}

vim.g.codeium_enabled = vim.g.ai.windsurf
-- vim.g.codeium_filetypes_disabled_by_default = true
-- vim.g.codeium_filetypes = vim.g.config.filetypes

-- NOTE: replaced with copilot.lua
vim.g.copilot_enabled = vim.g.ai.copilot
-- vim.g.copilot_filetypes = vim.g.config.filetypes

-- https://github.com/ravitemer/mcphub.nvim
-- https://ravitemer.github.io/mcphub.nvim/configuration.html

local node_prefix = vim.g.config.node.prefix or ''

local function should_attach(bufname)
  if not bufname or bufname:match('.env') then
    return false
  end
  local basename = vim.fs.basename(bufname)
  return not (basename:match('local.') or basename:match('.local'))
end

return {
  {
    'folke/sidekick.nvim',
    dependencies = {
      'folke/snacks.nvim',
    },
    enabled = vim.g.ai.sidekick and vim.fn.has('nvim-0.11.2'),
    version = 'v2.x',
    opts = {
      cli = {
        mux = {
          -- backend = vim.env.ZELLIJ and 'zellij' or 'tmux',
          enabled = true,
        },
        prompts = {
          refactor = 'Please refactor {this} to be more maintainable',
          security = 'Review {file} for security vulnerabilities',
          custom = function(ctx)
            return 'Current file: ' .. ctx.buf .. ' at line ' .. ctx.row
          end,
        },
      },
      nes = {
        enabled = false,
        --[[
        enabled = function(buf)
          local bufname = vim.api.nvim_buf_get_name(buf)
          if not should_attach(bufname) then
            return false
          end
          return vim.g.sidekick_nes ~= false and vim.b.sidekick_nes ~= false
        end,
        ]]
        --
      },
    },
    keys = {
      { '<leader>a', '', desc = '+ai', mode = { 'n', 'v' } },
      {
        '<tab>',
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require('sidekick').nes_jump_or_apply() then
            return '<Tab>' -- fallback to normal tab
          end
        end,
        expr = true,
        desc = 'Goto/Apply Next Edit Suggestion',
      },
      -- {
      --   '<tab>',
      --   function()
      --     -- if there is a next edit, jump to it, otherwise apply it if any
      --     if require('sidekick').nes_jump_or_apply() then
      --       return -- jumped or applied
      --     end
      --
      --     -- if you are using Neovim's native inline completions
      --     if vim.lsp.inline_completion.get() then
      --       return
      --     end
      --
      --     -- any other things (like snippets) you want to do on <tab> go here.
      --
      --     -- fall back to normal tab
      --     return '<tab>'
      --   end,
      --   mode = { 'i', 'n' },
      --   expr = true,
      --   desc = 'Goto/Apply Next Edit Suggestion',
      -- },
      {
        '<c-.>',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Sidekick Toggle',
        mode = { 'n', 't', 'i', 'x' },
      },
      {
        '<leader>aa',
        function()
          require('sidekick.cli').toggle()
        end,
        desc = 'Sidekick Toggle CLI',
      },
      {
        '<leader>as',
        function()
          require('sidekick.cli').select()
        end,
        -- Or to select only installed tools:
        -- require("sidekick.cli").select({ filter = { installed = true } })
        desc = 'Select CLI',
      },
      {
        '<leader>ad',
        function()
          require('sidekick.cli').close()
        end,
        desc = 'Detach a CLI Session',
      },
      {
        '<leader>at',
        function()
          require('sidekick.cli').send({ msg = '{this}' })
        end,
        mode = { 'x', 'n' },
        desc = 'Send This',
      },
      {
        '<leader>af',
        function()
          require('sidekick.cli').send({ msg = '{file}' })
        end,
        desc = 'Send File',
      },
      {
        '<leader>av',
        function()
          require('sidekick.cli').send({ msg = '{selection}' })
        end,
        mode = { 'x' },
        desc = 'Send Visual Selection',
      },
      {
        '<leader>ap',
        function()
          require('sidekick.cli').prompt()
        end,
        mode = { 'n', 'x' },
        desc = 'Sidekick Select Prompt',
      },
      -- Example of a keybinding to open Claude directly
      -- {
      --   '<leader>ac',
      --   function()
      --     require('sidekick.cli').toggle({ name = 'claude', focus = true })
      --   end,
      --   desc = 'Sidekick Toggle Claude',
      -- },
    },
  },
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
      -- cmd = vim.env.HOME .. '/.local/share/npm/bin/mcp-hub',

      -- cmd = node_prefix .. 'node',
      -- cmdArgs = { node_prefix .. 'mcp-hub' },

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
      -- acp_providers = {
      --   ['opencode'] = {
      --     command = 'opencode',
      --     args = { 'acp' },
      --     env = {
      --       OPENCODE_API_KEY = os.getenv('OPENCODE_API_KEY'),
      --     },
      --   },
      -- },

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
    'coder/claudecode.nvim',
    enabled = vim.g.ai.claude,
    version = 'v0.3.0',
    dependencies = { 'folke/snacks.nvim' },
    config = true,
    keys = {
      -- { '<leader>a', nil, desc = 'AI/Claude Code' },
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select Claude model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
      {
        '<leader>as',
        '<cmd>ClaudeCodeTreeAdd<cr>',
        desc = 'Add file',
        ft = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      },
      -- -- Diff management
      -- { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      -- { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
  },
  -- {
  --   'greggh/claude-code.nvim',
  --   enabled = vim.g.ai.claude,
  --   tag = 'v0.4.3',
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  --   cmd = { 'ClaudeCode', 'ClaudeCodeContinue', 'ClaudeCodeResume', 'ClaudeCodeVerbose' },
  --   keys = {
  --     { '<leader>cC', '<cmd>ClaudeCode<cr>', desc = 'Claude Code', mode = { 'n', 'v' } },
  --   },
  --   opts = {
  --     -- command = 'claude',
  --     -- keymaps = {
  --     --   toggle = {
  --     --     normal = '<C-,>', -- Normal mode keymap for toggling Claude Code, false to disable
  --     --     terminal = '<C-,>', -- Terminal mode keymap for toggling Claude Code, false to disable
  --     --     variants = {
  --     --       continue = '<leader>cC', -- Normal mode keymap for Claude Code with continue flag
  --     --       verbose = '<leader>cV', -- Normal mode keymap for Claude Code with verbose flag
  --     --     },
  --     --   },
  --     --   window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
  --     --   scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
  --     -- },
  --   },
  -- },
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
    event = 'VeryLazy', -- 'InsertEnter',
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
        filetypes = vim.g.config.filetypes,
        should_attach = function(_, bufname)
          if not should_attach(bufname) then
            return false
          end
          -- vim.print('Copilot attach: ' .. vim.fs.basename(bufname) or bufname)
          return true
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
        nes = {
          enabled = false, -- requires copilot-lsp as a dependency
          auto_trigger = false,
          keymap = {
            accept_and_goto = false,
            accept = false,
            dismiss = false,
          },
        },
        -- copilot_model = '',
        disable_limit_reached_message = true,
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
