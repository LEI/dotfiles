local home = os.getenv('HOME')
local tmp = os.getenv('TMPDIR') or '/tmp'

local function get_node_config()
  local node_version = ''
  local node_prefix = ''
  if vim.fn.executable('mise') == 1 then
    local mise_node_cmd = "mise list node --cd='" .. tmp .. "' --global --installed | awk '/^node / {print $2}'"
    node_version = vim.fn.system(mise_node_cmd):gsub('[\n\r]', '')
    -- mise list node --installed --json --quiet | jq --raw-output 'last .install_path' # /bin/
    if node_version ~= '' then
      node_prefix = home .. '/.local/share/mise/installs/node/' .. node_version .. '/bin/'
    end
  end
  -- Fallback to system node
  if node_version == '' and (vim.fn.executable('node') == 1) then
    node_version = vim.fn.system('node --version'):gsub('[\n\r]', '')
    node_version = string.gsub(node_version, '^v', '')
  end
  local node_major_version = tonumber(string.match(node_version, '^%d+'))
  if node_major_version == nil or node_major_version < 20 then
    vim.notify('node >=20 is required: ' .. node_version, vim.log.levels.ERROR)
  end
  if node_prefix ~= '' and vim.fn.filereadable(node_prefix .. 'node') ~= 1 then
    vim.notify('node prefix is not readable: ' .. node_prefix, vim.log.levels.ERROR)
  end
  return {
    prefix = node_prefix,
    version = node_version,
  }
end

local config = {
  colorscheme = 'nightfox',
  node = get_node_config(),
  signs = {
    done = '', -- ✓ ✔
    error = '✗', -- × ✕
    pending = '→', -- ➜ ➤
    -- info = 'ℹ', -- 
    spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  },
}

vim.g.config = config
vim.g.features = require('features')
vim.g.home = home
vim.g.tmp = tmp
