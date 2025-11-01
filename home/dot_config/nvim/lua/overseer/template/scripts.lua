-- https://github.com/stevearc/overseer.nvim/blob/master/doc/recipes.md#run-shell-scripts-in-the-current-directory
local files = require('overseer.files')

local function filter_scripts(file_name, base_dir)
  return file_name:match('%.*sh$')
    or file_name:match('%.nu$')
    or vim.fn.executable(files.join(base_dir, file_name)) == 1
end

return {
  generator = function(opts, cb)
    local cwd = vim.fn.getcwd()
    local dirs = { cwd }
    -- FIXME: duplicates when opening from a script dir
    -- if opts.dir ~= cwd and opts.dir ~= '.' then
    --   table.insert(dirs, opts.dir)
    -- end
    local ret = {}
    for _, dir in ipairs(dirs) do
      for _, dir_name in ipairs({ '.', 'bin', 'script', 'scripts' }) do
        local base_dir = files.join(dir, dir_name)
        if vim.fn.isdirectory(base_dir) == 1 then
          -- vim.print('Listing files in ' .. base_dir)
          local dir_files = files.list_files(base_dir)
          for _, file_name in ipairs(dir_files) do
            if filter_scripts(file_name, base_dir) then
              local file_path = files.join(base_dir, file_name)
              local relative_name = vim.fn.resolve(file_path):gsub('^' .. cwd, '.')
              table.insert(ret, {
                name = relative_name,
                params = {
                  args = { optional = true, type = 'list', delimiter = ' ' },
                  cwd = { optional = true },
                },
                builder = function(params)
                  return {
                    cmd = { relative_name },
                    args = params.args,
                    cwd = params.cwd,
                  }
                end,
              })
            end
          end
        end
      end
    end
    cb(ret)
  end,
}
