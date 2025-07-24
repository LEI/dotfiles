-- https://github.com/stevearc/overseer.nvim/blob/master/doc/recipes.md#run-shell-scripts-in-the-current-directory
local script_dirs = { 'bin', 'script', 'scripts' }
local files = require('overseer.files')

local function filter_scripts(filename, basedir)
  return filename:match('%.*sh$') or filename:match('%.nu$') or (vim.fn.executable(files.join(basedir, filename)) == 1)
end

return {
  generator = function(opts, cb)
    local cwd = vim.fn.getcwd()
    local dirs = { opts.dir or cwd }
    -- if opts.dir ~= cwd then
    --   table.insert(dirs, cwd)
    -- end
    local scripts = {}
    for _, dir in ipairs(dirs) do
      local list = files.list_files(dir)
      -- local scripts = vim.tbl_filter(filter_scripts, list)
      for _, filename in ipairs(list) do
        if filter_scripts(filename, dir) then
          local file = files.join(dir, filename)
          table.insert(scripts, file)
        end
      end
      for _, script_dir in ipairs(script_dirs) do
        local dir_path = files.join(dir, script_dir)
        for _, root_dir in ipairs(dirs) do
          if dir_path == root_dir then
            goto continue
          end
        end
        ::continue::
        if vim.fn.isdirectory(dir_path) == 1 then
          local sublist = files.list_files(dir_path)
          for _, filename in ipairs(sublist) do
            if filter_scripts(filename, dir_path) then
              table.insert(scripts, files.join(script_dir, filename))
            end
          end
        end
      end
    end
    local ret = {}
    for _, filename in ipairs(scripts) do
      table.insert(ret, {
        name = filename,
        params = {
          args = { optional = true, type = 'list', delimiter = ' ' },
          cwd = { optional = true },
        },
        builder = function(params)
          return {
            cmd = { filename },
            args = params.args,
            cwd = params.cwd,
          }
        end,
      })
    end
    cb(ret)
  end,
}
