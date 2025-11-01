return {
  {
    'mfussenegger/nvim-lint',
    dependencies = { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    -- branch = 'master',
    cmd = { 'Lint', 'LintInfo' },
    event = {
      'BufWritePre',
      -- 'CursorHold',
      'VeryLazy',
    },
    config = function()
      local common = {}
      local lint = require('lint')
      lint.linters_by_ft = {
        -- cspell = { 'markdown', 'plaintext' },
        dockerfile = { 'hadolint' },
        -- go = { 'golangcilint' },
        markdown = { 'markdownlint' },
        mysql = { 'sqlfluff' },
        php = { 'phpcs' }, -- 'php',
        plsql = { 'sqlfluff' },
        sql = { 'sqlfluff' }, -- 'sqlruff',
        yaml = { 'yamllint' },
        ['*'] = {},
      }
      for _, linter in pairs(lint.linters_by_ft) do
        for _, l in ipairs(common) do
          if not vim.tbl_contains(linter, l) then
            table.insert(linter, l)
          end
        end
      end
      local callback = function()
        if string.find(vim.bo.filetype, 'chezmoitmpl') then
          -- vim.print('Linting disabled')
          return
        end
        lint.try_lint()
      end
      local events = { 'BufEnter', 'BufWritePost', 'InsertLeave', 'VimEnter' }
      vim.api.nvim_create_autocmd(events, { callback = callback })
      vim.api.nvim_create_user_command('Lint', callback, { desc = 'Lint buffer' })
      vim.api.nvim_create_user_command('LintInfo', function()
        local available = lint.linters_by_ft[vim.bo.filetype] or lint.linters_by_ft['*']
        local running = lint.get_running()
        local text = 'nvim-lint\n'
          .. '\n'
          .. #available
          .. ' available:\n'
          .. table.concat(available, '\n')
          .. (#available > 0 and '\n' or '')
          .. '\n'
          .. #running
          .. ' running:\n'
          .. table.concat(running, '\n')
          .. (#running > 0 and '\n' or '')
        Snacks.win({
          text = text,
          -- width = 0.8,
          -- height = 0.8,
          bo = {
            modifiable = false,
            readonly = true,
          },
        })
      end, {})
    end,
  },
}
