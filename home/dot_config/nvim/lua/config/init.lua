vim.g.home = os.getenv('HOME')
vim.g.tmp = os.getenv('TMPDIR') or '/tmp'

local mise_installs = vim.g.home .. '/.local/share/mise/installs'

local function get_mise_node_version()
  local node_version = vim.env.MISE_GLOBAL_NODE_VERSION
  -- local match = vim.env.PATH:gsub('.*:' .. mise_installs .. '/node/([0-9\\.]+)/bin:.*', '%1')
  -- if match ~= vim.env.PATH then
  --   node_version = match
  if node_version == '' then
    node_version = nil
  end
  if not node_version and vim.fn.executable('mise') == 1 then
    local mise_node_cmd = "mise list node --cd='" .. vim.g.tmp .. "' --global --installed | awk '/^node / {print $2}'"
    node_version = vim.fn.system(mise_node_cmd):gsub('[\n\r]', '')
  end
  return node_version ~= '' and node_version or nil
end

local function get_node_config()
  local node_prefix = nil
  local node_version = get_mise_node_version()
  if node_version then
    -- Use global mise node
    node_prefix = mise_installs .. '/node/' .. node_version .. '/bin/'
  elseif not node_version and (vim.fn.executable('node') == 1) then
    -- Fallback to system node
    node_version = vim.fn.system('node --version'):gsub('[\n\r]', '')
    node_version = string.gsub(node_version, '^v', '')
  end
  if not node_version or node_version == '' then
    vim.notify('node version not found', vim.log.levels.WARN)
    return {}
  end
  if node_prefix and vim.fn.filereadable(node_prefix .. 'node') ~= 1 then
    vim.notify('node prefix is not readable: ' .. node_prefix, vim.log.levels.WARN)
  end
  local node_major_version = node_version and tonumber(string.match(node_version, '^%d+')) or nil
  if node_major_version == nil or node_major_version < 20 then
    vim.notify('node >=20 is required' .. (node_version and ': ' .. node_version or ''), vim.log.levels.WARN)
  end
  return {
    prefix = node_prefix,
    version = node_version,
  }
end

vim.g.config = {
  explorer = 'oil',
  node = get_node_config(),
  signs = {
    done = '', -- ✓ ✔
    error = '✗', -- × ✕
    pending = '→', -- ➜ ➤
    -- info = 'ℹ', -- 
    spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  },
  theme = {
    -- colorscheme = 'nightfox',
    -- colorscheme = 'rose-pine',
    colorscheme = 'tokyonight',
    dim_inactive = true,
    transparent = false,
  },
}

vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = vim.g.config.signs.error,
  [vim.diagnostic.severity.WARN] = '!',
  [vim.diagnostic.severity.INFO] = 'i',
  [vim.diagnostic.severity.HINT] = '?',
}

local features_json_file = vim.g.home .. '/.local/share/features.json'
local features_contents = vim.fn.readfile(features_json_file)
vim.g.features = vim.json.decode(table.concat(features_contents, '\n'))
