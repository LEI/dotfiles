return {
  -- Alternative: https://github.com/debugloop/telescope-undo.nvim
  -- or Snacks.picker.undo()
  {
    'mbbill/undotree',
    tag = 'rel_6.1',
    -- lazy = false,
    cmd = {
      'UndotreeFocus',
      'UndotreeHide',
      'UndotreeShow',
      'UndotreeToggle',
    },
    keys = {
      { '<leader>U', '<cmd>UndotreeToggle<cr>', desc = 'Toggle undo tree' },
    },
  },
}
