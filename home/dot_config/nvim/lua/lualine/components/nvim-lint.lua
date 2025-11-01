local M = require('lualine.component'):extend()

M.done_icon = vim.g.config.signs.lint_done or 'OK'
M.running_icon = vim.g.config.signs.lint_running or 'RUNNING'
M.separator = ' '

-- Initializer
function M:init(options)
  M.super.init(self, options)
end

-- Function that runs every time statusline is updated
-- function M:update_status()
--   local lint = require('lint')
--   if vim.bo.filetype == '' or vim.bo.filetype == 'help' then
--     return ''
--   end
--   local available = lint.linters_by_ft[vim.bo.filetype] or nil
--   if available == nil then
--     return ''
--   end
--   local linters = lint.get_running()
--   if #linters == 0 then
--     return '󰦕' -- .. (available and ' ' or '') .. table.concat(available, ', ')
--   end
--   -- return '󱉶 ' .. table.concat(linters, ', ')
--   return table.concat(linters, ', ') .. ' 󱉶'
-- end

function M:update_status()
  local lint = require('lint')
  if vim.bo.filetype == '' or vim.bo.filetype == 'help' then
    return ''
  end
  local available = lint.linters_by_ft[vim.bo.filetype] or {}
  local linters = lint.get_running()
  if #available == 0 and #linters == 0 then
    return
  end
  local all = {}
  for _, name in pairs(available) do
    -- table.insert(linters, name)
    all[name] = false
  end
  for _, name in pairs(linters) do
    -- linters[index] = name .. M.done_icon
    all[name] = true
  end
  local keys = {}
  for name, running in pairs(all) do
    local sign = running and M.running_icon or M.done_icon
    table.insert(keys, sign .. ' ' .. name)
  end
  return table.concat(keys, M.separator)
end

return M
