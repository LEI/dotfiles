local enabled = {
  -- avante = true,
  codecompanion = true,
  codeium = false,
  copilot = false,
  copilot_lua = true
}
local filetypes = {
  javascript = true,
  lua = true,

  rust = true,
  sh = function()
    -- Disable for .env files
    return not string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*')
  end,
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
-- local home = vim.fn.expand('$HOME')
local wk = require('which-key')

-- Alternatives:
-- https://github.com/A7Lavinraj/assistant.nvim
-- https://github.com/CopilotC-Nvim/CopilotChat.nvim
-- https://github.com/jackMort/ChatGPT.nvim

-- https://github.com/ravitemer/mcphub.nvim
-- https://ravitemer.github.io/mcphub.nvim/configuration.html

-- TODO: add helper to exec and capture the output of an external command
local node_json_cmd = 'mise list node --installed --json --quiet | jq --compact-output --raw-output last'
local node_json_result = vim.api.nvim_exec2('!' .. node_json_cmd, { output = true, })
local node_json = vim.split(node_json_result.output, '\n')[3]
local success, node_info = pcall(vim.json.decode, node_json)
local npx = 'npx'
if success then
  -- local node_version = node_info.version
  local node_install_path = node_info.install_path
  npx = node_install_path .. '/bin/npx'
else
  print('Failed to decode node info: ' .. node_json)
end

-- TODO: run once on plugin nstall or update and check node >=20
-- local node_install_path = home .. '/.local/share/mise/installs/node/' .. node_version
-- local npm = node_install_path .. '/bin/npm'
-- local cmd = 'command -v mcp-hub >/dev/null || ' .. npm .. ' install --global --quiet mcp-hub@latest'
-- vim.fn.jobstart({ 'sh', '-c', cmd }, { detach = false })

require('mcphub').setup({
  auto_approve = false,
  auto_toggle_mcp_servers = true,

  use_bundled_binary = true,

  -- cmd = 'node',
  -- cmdArgs = { '/path/to/mcp-hub/src/utils/cli.js' },
  cmd = npx,
  cmdArgs = { '-y', 'mcp-hub@latest' },

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
if enabled.avante then
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
-- https://codecompanion.olimorris.dev/installation.html#additional-plugins
-- Alternative: https://github.com/OXY2DEV/markview.nvim
if enabled.codecompanion then
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  -- :TSInstall markdown markdown_inline
  require('render-markdown').setup({
    completions = { lsp = { enabled = true } },
    file_types = { 'markdown', 'codecompanion' },
    only_render_image_at_cursor = true,
    preset = 'none', -- none, obsidian, lazy
  })
  -- https://github.com/echasnovski/mini.diff
  -- https://github.com/hakonharnes/img-clip.nvim
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

-- https://github.com/zbirenbaum/copilot.lua
-- :Copilot auth
if enabled.copilot_lua then
  vim.api.nvim_create_autocmd('InsertEnter', {
    once = true,
    callback = function(opts)
      require('copilot').setup({
        -- auth_provider_url = 'https://github.com',
        -- copilot_node_command = home .. '/.config/nvm/versions/node/v20.0.1/bin/node',
        -- workspace_folders = {
        --   vim.fn.expand('$HOME') .. '/src/*/*',
        -- },
        filetypes = filetypes,
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

-- NOTE: replaced with copilot.lua
-- https://github.com/github/copilot.vim
-- :Copilot setup
vim.g.copilot_enabled = enabled.copilot
-- vim.g.copilot_filetypes = {}

-- https://github.com/Exafunction/windsurf.vim
-- :Codeium Auth
vim.g.codeium_enabled = enabled.codeium
-- vim.g.codeium_filetypes_disabled_by_default = true
-- vim.g.codeium_filetypes = {}
if enabled.codeium then
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
