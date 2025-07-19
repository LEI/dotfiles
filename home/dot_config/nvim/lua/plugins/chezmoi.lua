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
    -- formatters = { file = { truncate = 80 } },
    -- win = { preview = { title = '{preview}' } },
  }
  Snacks.picker.pick(opts)
end

return {
  {
    -- highlighting for chezmoi files template files
    'alker0/chezmoi.vim',
    init = function()
      vim.g['chezmoi#use_tmp_buffer'] = 1
      vim.g['chezmoi#source_dir_path'] = vim.g.home .. '/.local/share/chezmoi'
    end,
  },
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
    opts = {
      edit = {
        watch = false,
        force = false,
      },
      notification = {
        on_open = true,
        on_apply = true,
        on_watch = false,
      },
    },
    init = function(_, opts)
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = { vim.g.home .. '/.local/share/chezmoi/*' },
        callback = function(ev)
          local bufnr = ev.buf

          if
            vim.bo[bufnr].filetype == 'gitcommit'
            or vim.bo[bufnr].filetype == 'gitrebase'
            or vim.bo[bufnr].filetype == 'diff'
            or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t'):match('^%.chezmoi')
          then
            return
          end

          local edit_watch = function()
            require('chezmoi.commands.__edit').watch(bufnr)
          end
          vim.schedule(edit_watch)
        end,
      })
      vim.api.nvim_create_user_command('ChezmoiFind', chezmoi_picker, { desc = 'Search dotfiles (chezmoi)' })
    end,
  },
  {
    'echasnovski/mini.icons',
    tag = 'v0.16.0',
    lazy = true,
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
      -- style = 'ascii', -- Default: glyph
    },
  },
}
