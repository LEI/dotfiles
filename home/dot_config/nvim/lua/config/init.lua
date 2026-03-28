local preset = require('config.preset')
-- vim.env.HOME = vim.env.HOME or os.getenv('HOME') or os.getenv('USERPROFILE')
vim.env.TMP = vim.env.TMP or os.getenv('TMP') or os.getenv('TMPDIR') or '/tmp'

local mise_installs = vim.env.HOME .. '/.local/share/mise/installs'

local function get_mise_node_version()
  if vim.fn.executable('mise') ~= 1 then
    return nil
  end
  local node_path = vim.fn.system('mise where node@lts 2>/dev/null'):gsub('[\n\r]', '')
  if node_path ~= '' then
    return node_path:match('([^/]+)$')
  end
  return nil
end

local function get_node_config()
  local node_prefix = nil
  local node_version = get_mise_node_version()
  if node_version then
    -- Use global mise node
    local os_separator = package.config:sub(1, 1)
    node_prefix = vim.fn.resolve(mise_installs .. '/node/' .. node_version .. '/bin') .. os_separator
  elseif not node_version and (vim.fn.executable('node') == 1) then
    -- Fallback to system node
    node_version = vim.fn.system('node --version'):gsub('[\n\r]', '')
    node_version = string.gsub(node_version, '^v', '')
  end
  if not node_version or node_version == '' then
    vim.notify('node version not found', vim.log.levels.WARN)
    return {}
  end
  local node_path = node_prefix and node_prefix .. 'node' or nil
  if node_path and vim.fn.filereadable(node_path) ~= 1 then
    vim.notify('node path is not readable: ' .. node_path, vim.log.levels.WARN)
    return {}
  end
  local node_major_version = node_version and tonumber(string.match(node_version, '^%d+')) or nil
  if node_major_version == nil or node_major_version < 20 then
    vim.notify('node >=20 is required' .. (node_version and ': found ' .. node_version or ''), vim.log.levels.WARN)
  end
  return {
    prefix = node_prefix,
    version = node_version,
  }
end

vim.g.config = {
  backdrop = 100, -- 60,
  -- "bold": Bold line box
  -- "double": Double-line box
  -- "none": No border
  -- "rounded": Like "single", but with rounded corners ("╭" etc.)
  -- "shadow": Drop shadow effect, by blending with the background
  -- "single": Single-line box
  -- "solid": Adds padding by a single whitespace cell
  border = 'rounded',
  explorer = 'oil',
  node = get_node_config(),
  preset = preset.name,
  signs = preset.signs,
  theme = {
    -- colorscheme = 'nightfox',
    -- colorscheme = 'rose-pine',
    colorscheme = os.getenv('COLORSCHEME') or 'tokyonight',
    dim_inactive = os.getenv('DIM_INACTIVE') == 'true' or true,
    transparent = os.getenv('TRANSPARENT_BACKGROUND') == 'true',
  },
  lazy = {
    -- Install missing lazy.nvim plugins on startup
    install_missing = true, -- FIXME: breaks session restore
  },
  mason = {
    -- Install tools on startup
    run_on_start = true,
  },
  treesitter = {
    -- Automatically install missing parsers when entering buffer
    auto_install = true,
    -- Always install the listed parsers
    ensure_installed = false,
  },
  filetypes = {
    -- css = true, -- less, scss...
    dockerfile = true,
    go = true,
    hcl = true,
    html = true,
    javascript = true,
    lua = true,
    nginx = true,
    nu = true,
    php = true,
    python = true,
    ruby = true,
    rust = true,
    sh = function()
      return not string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), '^%.env.*')
    end,
    sql = true,
    terraform = true,
    typescript = true,
    vim = true,

    -- yaml = false,
    -- markdown = false,
    -- help = false,
    -- gitcommit = false,
    -- gitrebase = false,
    -- hgcommit = false,
    -- svn = false,
    -- cvs = false,
    -- ['.'] = false,
    ['*'] = false,
  },
}

vim.g.diagnostic_signs = {
  [vim.diagnostic.severity.ERROR] = vim.g.config.signs.error,
  [vim.diagnostic.severity.WARN] = vim.g.config.signs.warn,
  [vim.diagnostic.severity.INFO] = vim.g.config.signs.info,
  [vim.diagnostic.severity.HINT] = vim.g.config.signs.hint,
}

vim.g.features = {}
local features_json_file = vim.env.HOME .. '/.local/state/chezmoi/features.json'
if vim.fn.filereadable(features_json_file) == 1 then
  local ok, result = pcall(function()
    local contents = vim.fn.readfile(features_json_file)
    return vim.json.decode(table.concat(contents, '\n'))
  end)
  if ok then
    vim.g.features = result
  else
    vim.notify('features.json: ' .. tostring(result), vim.log.levels.WARN)
  end
end

-- vim.g.profile = vim.env.CHEZMOI_PROFILE or nil

-- vim.o.winborder = vim.g.config.border

vim.cmd.aunmenu([[PopUp.How-to\ disable\ mouse]])
-- vim.cmd.amenu([[PopUp.:Inspect <cmd>Inspect<cr>]])
-- vim.cmd.amenu([[PopUp.:Telescope <cmd>Telescope<cr>]])
vim.cmd.amenu([[PopUp.Code\ action <cmd>lua vim.lsp.buf.code_action()<cr>]])
vim.cmd.amenu([[PopUp.LSP\ Hover <cmd>lua vim.lsp.buf.hover()<cr>]])
