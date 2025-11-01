-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- Highlight on yank
-- vim.api.nvim_create_autocmd('TextYankPost', {
--   group = vim.api.nvim_create_augroup('highlight_yank', { clear = true }),
--   callback = function()
--     (vim.hl or vim.highlight).on_yank()
--   end,
-- })

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = vim.api.nvim_create_augroup('resize_splits', { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- Restore cursor position
-- https://github.com/neovim/neovim/issues/16339#issuecomment-1457394370
-- vim.api.nvim_create_autocmd('BufRead', {
--   callback = function(opts)
--     vim.api.nvim_create_autocmd('BufWinEnter', {
--       once = true,
--       buffer = opts.buf,
--       callback = function()
--         local ft = vim.bo[opts.buf].filetype
--         local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
--         if
--           not (ft:match('commit') and ft:match('rebase'))
--           and last_known_line > 1
--           and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
--         then
--           vim.api.nvim_feedkeys([[g`"]], 'nx', false)
--         end
--       end,
--     })
--   end,
-- })
-- Go to last loc when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('last_loc', { clear = true }),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('close_with_q', { clear = true }),
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd('close')
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- Make it easier to close man-files when opened inline
-- vim.api.nvim_create_autocmd('FileType', {
--   group = vim.api.nvim_create_augroup('man_unlisted', { clear = true }),
--   pattern = { 'man' },
--   callback = function(event)
--     vim.bo[event.buf].buflisted = false
--   end,
-- })

-- Wrap and check for spell in text filetypes and hide inline diagnostics
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('wrap_spell', { clear = true }),
  pattern = { 'text', 'plaintext', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
-- vim.api.nvim_create_autocmd({ 'FileType' }, {
--   group = vim.api.nvim_create_augroup('json_conceal', { clear = true }),
--   pattern = { 'json', 'jsonc', 'json5' },
--   callback = function()
--     vim.opt_local.conceallevel = 0
--   end,
-- })

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.fn.has('win32') == 0 and vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Always restore session if one exists
-- https://github.com/folke/persistence.nvim/issues/13
vim.g.sessions_dir = vim.fn.stdpath('state') .. '/sessions/'
vim.api.nvim_create_autocmd('VimEnter', {
  nested = true,
  group = vim.api.nvim_create_augroup('RestoreSession', { clear = true }),
  callback = function()
    local cwd = vim.fn.getcwd()
    -- TODO: or vim.g.started_with_stdin
    -- vim.fn.argc(): number of files in the argument list
    local has_args = #vim.v.argv > 2
    local session_file = vim.g.sessions_dir .. cwd:gsub('/', '%%') .. '.vim'
    local session_exists = vim.fn.filereadable(session_file) == 1
    if not has_args and session_exists then
      vim.notify('Loading session: ' .. vim.fn.fnamemodify(cwd, ':~'))
      require('persistence').load()
    elseif has_args and (not vim.list_contains(vim.v.argv, '+Restore')) and session_exists then
      vim.notify('Stopping persistence (session exists)', vim.log.levels.WARN)
      require('persistence').stop()
      vim.g.current_session = false
    end
  end,
})
