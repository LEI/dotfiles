return {
  {
    'tpope/vim-dadbod',
    tag = 'v1.4',
    dependencies = { 'kristijanhusak/vim-dadbod-completion' },
    cmd = 'DB',
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      -- 'tpope/vim-dotenv',
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = {
      'DBUI',
      'DBUIAddConnection',
      'DBUIFindBuffer',
      'DBUIToggle',
    },
    keys = {
      { '<leader>OD', '<cmd>DBUIToggle<cr>', desc = 'Dadbod UI (DBUI)', mode = { 'n', 'v' } },
    },
    init = function()
      -- vim.g.db_ui_auto_execute_table_helpers = 1
      -- vim.g.db_ui_disable_mappings_dbui = 1
      -- autocmd FileType dbui nmap <buffer> v <Plug>(DBUI_SelectLineVsplit)
      -- call db_ui#utils#set_mapping('<c-k>', '<Plug>(DBUI_GotoFirstSibling)')
      -- call db_ui#utils#set_mapping('<c-j>', '<Plug>(DBUI_GotoLastSibling)')
    end,
    config = function()
      -- vim.cmd('Dotenv')
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
}
