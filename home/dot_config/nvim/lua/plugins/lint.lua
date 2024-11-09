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
      local lint = require('lint')
      -- NOTE: node >=20 is required for cspell
      -- lint.linters.cspell = require('lint.util').wrap(lint.linters.cspell, function(diagnostic)
      --   diagnostic.severity = vim.diagnostic.severity.HINT
      --   return diagnostic
      -- end)
      lint.linters_by_ft = {
        dockerfile = { 'hadolint' },
        -- markdown = { 'vale' },
        mysql = { 'sqlfluff' },
        php = { 'phpcs' }, -- 'php',
        plsql = { 'sqlfluff' },
        sql = { 'sqlfluff' }, -- 'sqlruff',
        yaml = { 'yamllint' },
        ['*'] = {},
      }
      -- for ft in pairs(lint.linters_by_ft) do
      --   table.insert(lint.linters_by_ft[ft], 'cspell')
      -- end
      local callback = function()
        lint.try_lint()
        -- lint.try_lint('cspell')
      end
      local events = { 'BufEnter', 'BufWritePost', 'InsertLeave', 'VimEnter' }
      vim.api.nvim_create_autocmd(events, { callback = callback })
      vim.api.nvim_create_user_command('Lint', callback, { desc = 'Lint buffer' })
      vim.api.nvim_create_user_command('LintInfo', function()
        local available = table.concat(lint.linters_by_ft[vim.bo.filetype] or lint.linters_by_ft['*'], ', ')
        local running = table.concat(lint.get_running(), '\n')
        vim.notify('Linters: ' .. available, vim.log.levels.INFO, { title = 'nvim-lint' })
        vim.notify('Running: ' .. running, vim.log.levels.INFO, { title = 'nvim-lint' })
      end, {})
    end,
  },
}
