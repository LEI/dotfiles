-- https://github.com/davidosomething/dotfiles/blob/master/nvim/lua/dko/filetypes.lua
vim.filetype.add({
  extension = {
    -- conf = 'conf',
    env = 'dotenv',
  },
  filename = {
    -- ['.dockerignore'] = 'gitignore',
    ['.env'] = 'dotenv',
    -- ['.eslintrc.json'] = 'jsonc',
    -- ['.ignore'] = 'gitignore',
    ['.yamlfmt'] = 'yaml',
    ['.yamllint'] = 'yaml',
    ['devcontainer.json'] = 'jsonc',
    ['cspell.json'] = 'jsonc',
    ['project.json'] = 'jsonc', -- assuming nx project.json
  },
  pattern = {
    -- ['%.conf'] = {
    --   ['/%.ssh/.*%.conf$'] = 'sshconfig',
    -- },
    ['%.env%.[%w_.-]+'] = 'dotenv',
    ['.*/private_dot_ssh/.*%.conf'] = 'sshconfig',
    ['.vscode/*.json'] = 'jsonc',
    -- ['compose.y.?ml'] = 'yaml.docker-compose',
    -- ['docker%-compose%.y.?ml'] = 'yaml.docker-compose',
    -- ['tsconfig%.'] = 'jsonc',
  },
})
