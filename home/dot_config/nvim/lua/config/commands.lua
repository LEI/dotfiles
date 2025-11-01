-- https://github.com/folke/lazy.nvim/discussions/1188
-- https://github.com/LazyVim/LazyVim/discussions/3679
local get_action = function(action)
  return function(args)
    -- To detect if a UI is available, check if nvim_list_uis() is
    -- empty during or after VimEnter.
    -- vim.autocmd('VimEnter')
    -- local headless = #vim.api.nvim_list_uis() == 0

    vim.print(action .. ' packages...')
    vim.cmd('Lazy' .. (args.bang and '!' or '') .. ' ' .. string.lower(action))

    vim.print(action .. ' parsers...')
    vim.cmd('TSUpdate' .. (args.bang and 'Sync' or ''))

    -- FIXME: vim.lsp.config may be nil when headless
    -- https://github.com/mason-org/mason-lspconfig.nvim/blob/v2.0.0/lua/mason-lspconfig/mappings.lua#L28

    -- automatic_enable.lua:47: attempt to call field 'enable' (a nil value)
    -- https://github.com/mason-org/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/features/automatic_enable.lua#L47

    vim.print(action .. ' tools...')
    vim.cmd('MasonTools' .. action .. (args.bang and 'Sync' or ''))
  end
end
vim.api.nvim_create_user_command('LazyInstall', get_action('Install'), { desc = 'Install', bang = true })
vim.api.nvim_create_user_command('LazyUpdate', get_action('Update'), { desc = 'Update', bang = true })

if os.getenv('SHPOOL_SESSION_NAME') then
  vim.api.nvim_create_user_command('ShpoolDetach', function()
    vim.cmd('silent !shpool detach')
  end, { desc = 'shpool detach' })
  -- vim.keymap.set('n', '<leader>SD', '<cmd>ShpoolDetach<cr>', { desc = 'shpool detach' })
  -- https://github.com/shell-pool/shpool/issues/71#issuecomment-2632396805
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-a>d', '<cmd>ShpoolDetach<cr>', { desc = 'shpool detach' })
end
