-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/util/chezmoi.lua
local function chezmoi_picker()
  local args = {
    '--path-style=absolute',
    '--include=files',
    '--exclude=externals',
  }
  local cmd = 'chezmoi ' .. vim.fn.join(args, ' ')
  local results = require('chezmoi.commands').list({
    args = args,
  })
  local items = {}

  for _, czFile in ipairs(results) do
    table.insert(items, {
      text = czFile,
      file = czFile,
    })
  end

  ---@type snacks.picker.Config
  local opts = {
    title = cmd,
    items = items,
    confirm = function(picker, item)
      picker:close()
      require('chezmoi.commands').edit({
        targets = { item.text },
        args = { '--watch' },
      })
    end,
    formatters = { file = { truncate = 80 } },
    -- win = { preview = { title = '{preview}' } },
  }
  Snacks.picker.pick(opts)
end

return {
  {
    'xvzc/chezmoi.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
    },
    cmd = { 'ChezmoiEdit', 'ChezmoiFind', 'ChezmoiList' },
    keys = {
      { '<leader>sC', chezmoi_picker, desc = 'Search dotfiles (chezmoi)' },
    },
    opts = {},
    init = function(_, opts)
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = {
          vim.g.home .. '/.dotfiles/home',
          vim.g.home .. '/.local/share/chezmoi/home/*',
          vim.g.home .. '/src/*/*/dotfiles/home',
        },
        callback = function(ev)
          local bufnr = ev.buf
          local edit_watch = function()
            require('chezmoi.commands.__edit').watch(bufnr)
          end
          vim.schedule(edit_watch)
        end,
      })
      vim.api.nvim_create_user_command('ChezmoiFind', chezmoi_picker, { desc = 'Search dotfiles (chezmoi)' })
    end,
  },
  -- {
  --   'folke/snacks.nvim',
  --   optional = true,
  --   opts = function(_, opts)
  --     local chezmoi_entry = {
  --       icon = ' ',
  --       key = 'c',
  --       desc = 'Config',
  --       action = chezmoi_picker,
  --     }
  --     local config_index
  --     for i = #opts.dashboard.preset.keys, 1, -1 do
  --       if opts.dashboard.preset.keys[i].key == 'c' then
  --         table.remove(opts.dashboard.preset.keys, i)
  --         config_index = i
  --         break
  --       end
  --     end
  --     table.insert(opts.dashboard.preset.keys, config_index, chezmoi_entry)
  --   end,
  -- },
  {
    'echasnovski/mini.icons',
    opts = {
      file = {
        ['.chezmoiignore'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['.chezmoiremove'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['.chezmoiroot'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['.chezmoiversion'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['bash.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['json.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['ps1.tmpl'] = { glyph = '󰨊', hl = 'MiniIconsGrey' },
        ['sh.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['toml.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['yaml.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
        ['zsh.tmpl'] = { glyph = '', hl = 'MiniIconsGrey' },
      },
    },
  },
}
