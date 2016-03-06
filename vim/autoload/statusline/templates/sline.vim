" Tomorrow

let s:template = [
\  {
\    'string': ' %{statusline#core#mode()} ',
\    'highlight': 'mode',
\    'width': '-8',
\    'truncate': 20,
\  },
\  {
\    'string': '%{statusline#core#paste()} ',
\  },
\  {
\    'list': [
\      {
\        'string': ' %{get(g:statusline_symbols,"branch","on")} ',
\        'truncate': 20,
\      },
\      {
\        'string': '%{fugitive#head(7)} ',
\        'truncate': 40,
\      },
\    ],
\    'highlight': 'default',
\    'condition': 'exists("*fugitive#head") && strlen(fugitive#head(7)) > 0',
\  },
\  {
\    'string': ' %<%n ',
\    'highlight': 'base',
\  },
\  {
\    'string': '%f %([%M%R] %)',
\    'highlight': 'file',
\  },
\  {
\    'string': '%{statusline#core#crypt()} ',
\  },
\  '%=',
\  {
\    'string': ' %{v:register} ',
\    'highlight': 'bg',
\  },
\  {
\    'string': ' %{statusline#core#type()} ',
\    'highlight': 'base',
\    'truncate': 40,
\  },
\  {
\    'list': [
\      { 'string': ' %{&fileformat}' },
\      { 'string': '%{statusline#core#encoding()} ' },
\    ],
\    'highlight': 'default',
\    'truncate': 80,
\    'sep': get(g:statusline_symbols, 'separator', ' ')
\  },
\  {
\    'list': [
\      { 'string': ' %P ', 'width': '5' },
\      { 'string': ' %l', 'width': '4' },
\      { 'string': ':' },
\      { 'string': '%c%V ', 'width': '-4' },
\    ],
\    'highlight': 'mode',
\    'truncate': 60,
\  },
\  {
\    'string': ' %{SyntasticStatuslineFlag()} ',
\    'highlight': 'warning',
\    'condition': 'exists(":SyntasticCheck")',
\  },
\]

function statusline#templates#sline#apply()
  return s:template
endfunction
