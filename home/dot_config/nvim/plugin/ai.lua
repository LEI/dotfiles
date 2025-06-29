local enabled = 'copilot'
local home = vim.fn.expand('$HOME')
local wk = require('which-key')

-- Alternatives:
-- https://github.com/A7Lavinraj/assistant.nvim
-- https://github.com/CopilotC-Nvim/CopilotChat.nvim
-- https://github.com/jackMort/ChatGPT.nvim

-- https://github.com/ravitemer/mcphub.nvim
-- https://ravitemer.github.io/mcphub.nvim/configuration.html
require('mcphub').setup({
  auto_approve = false,
  auto_toggle_mcp_servers = true,

  -- TODO(lazy): build = 'bundled_build.lua',
  -- NOTE: use global node >=20 (ignore current working directory .tool-versions)
  -- npm install -g mcp-hub@latest
  cmd = home .. '/.local/share/mise/installs/node/24.2.0/bin/npx', -- 'node',
  cmdArgs = { '-y', 'mcp-hub' },                                   -- { '/path/to/mcp-hub/src/utils/cli.js' },
  use_bundled_binary = false,

  -- config = vim.fn.expand('~/.config/mcphub/servers.json'),
  -- port = 37373,
  -- server_url = 'http://localhost:37373',

  extensions = {
    avante = {
      make_slash_commands = true, -- make /slash commands from MCP server prompts
    }
  },
})

-- TODO: run make on install or update
-- https://github.com/yetone/avante.nvim
-- require('img-clip').setup()
-- require('render-markdown').setup()
vim.opt.laststatus = 3

-- https://github.com/yetone/avante.nvim#default-setup-configuration
if enabled == 'avante' then
  require('avante').setup({
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
    system_prompt = function()
      local hub = require('mcphub').get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ''
    end,
    -- Using function prevents requiring mcphub before it's loaded
    custom_tools = function()
      return {
        require('mcphub.extensions.avante').mcp_tool(),
      }
    end,
  })
  wk.add({
    {
      '<leader>C',
      '<cmd>AvanteToggle<cr>',
      desc = 'Avante',
      mode = { 'n', 'v' },
    },
  })
end

-- https://github.com/olimorris/codecompanion.nvim
if enabled == 'codecompanion' then
  require('codecompanion').setup({
    -- https://ravitemer.github.io/mcphub.nvim/extensions/codecompanion.html
    extensions = {
      mcphub = {
        callback = 'mcphub.extensions.codecompanion',
        opts = {
          show_result_in_chat = true, -- Show mcp tool results in chat
          make_vars = true,           -- Convert resources to #variables
          make_slash_commands = true, -- Add prompts as /slash commands
        }
      }
    },
    opts = {
      log_level = 'DEBUG', -- or 'TRACE'
    },
  })
  wk.add({
    {
      '<leader>C',
      '<cmd>CodeCompanionChat Toggle<cr>',
      -- :CodeCompanion <prompt>
      desc = 'Code Companion Chat',
      mode = { 'n', 'v' },
    },
  })
end

-- TODO: lazy load
-- https://github.com/zbirenbaum/copilot.lua
-- :Copilot auth
if enabled == 'copilot' then
  vim.api.nvim_create_autocmd('InsertEnter', {
    once = true,
    callback = function(opts)
      require('copilot').setup({
        -- auth_provider_url = 'https://github.com',
        -- copilot_node_command = home .. '/.config/nvm/versions/node/v20.0.1/bin/node',
        -- workspace_folders = {
        --   vim.fn.expand('$HOME') .. '/src/*/*',
        -- },
        filetypes = {
          javascript = true,
          lua = true,

          rust = true,
          sh = function()
            -- Disable for .env files
            return not string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*')
          end,
          typescript = true,

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
        },
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<M-l>',
            accept_word = false,
            accept_line = false,
            next = '<M-j>',    -- '<M-]>',
            prev = '<M-k>',    -- '<M-[>',
            dismiss = '<M-h>', -- '<C-]>',
          },
        },
      })
    end,
  })
end

-- https://github.com/github/copilot.vim
-- :Copilot setup
vim.g.copilot_enabled = false -- enabled == 'copilot'
-- vim.g.copilot_filetypes = {}

-- https://github.com/Exafunction/windsurf.vim
-- :Codeium Auth
vim.g.codeium_enabled = enabled == 'codeium'
-- vim.g.codeium_filetypes_disabled_by_default = true
-- vim.g.codeium_filetypes = {}
if enabled == 'codeium' then
  wk.add({
    {
      '<leader>C',
      '<cmd>Codeium Chat<cr>',
      desc = 'Codeium Chat',
      mode = { 'n', 'v' },
    },
  })
  -- vim.g.codeium_disable_bindings = true
  -- vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
  -- vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
  -- vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
  -- vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
end
