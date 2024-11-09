vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
  pattern = {
    -- '{t,j}sconfig.json',
    'devcontainer.json',
    '.vscode/*.json',
  },
  callback = function()
    vim.bo.filetype = 'jsonc'
  end,
})
