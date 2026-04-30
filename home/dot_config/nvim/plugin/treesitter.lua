-- https://mise.jdx.dev/mise-cookbook/neovim.html
vim.treesitter.query.add_predicate('is-mise?', function(_, _, bufnr, _)
  local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
  local filename = vim.fn.fnamemodify(filepath, ':t')
  return string.match(filename, '.*mise.*%.toml$') ~= nil
    or string.match(filename, '.*mise.*%.toml%.tmpl$') ~= nil
    or string.match(filepath, '.*mise/config%.toml$') ~= nil
    or string.match(filepath, '.*mise/config%.toml%.tmpl$') ~= nil
end, { force = true, all = false })
