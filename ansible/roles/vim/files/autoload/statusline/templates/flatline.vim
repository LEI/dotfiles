" Fat Line

" 'separator': get(g:statusline.symbols, 'separator', ':'),

let s:template = [
\  {
\    'string': ' %{statusline#core#mode()} ',
\    'highlight': 1,
\    'width': '-8',
\    'truncate': 20,
\  },
\  {
\    'string': '%{statusline#core#paste()} ',
\  },
\  {
\    'list': [
\      {
\        'string': ' %{get(g:statusline.symbols,"branch","on")} ',
\        'truncate': 20,
\      },
\      {
\        'string': '%{fugitive#head(7)} ',
\        'truncate': 40,
\      },
\    ],
\    'highlight': 2,
\    'condition': 'exists("*fugitive#head") && strlen(fugitive#head(7)) > 0',
\  },
\  {
\    'string': '%( %{statusline#core#crypt()}%)',
\    'highlight': 3,
\  },
\  {
\    'string': ' %<%n ',
\    'highlight': 3,
\  },
\  {
\    'list': [
\      { 'string': '%{statusline#core#file()} ' },
\      { 'string': '[%{statusline#core#flags()}] ' },
\    ],
\    'highlight': 3,
\  },
\  '%=',
\  {
\    'string': ' %{v:register} ',
\    'highlight': 4,
\  },
\  {
\    'list': [
\      { 'string': ' %{statusline#core#type()} ' },
\    ],
\    'highlight': 3,
\    'truncate': 40,
\  },
\  {
\    'list': [
\      { 'string': ' %{statusline#extensions#netrw#sortBy()} ' },
\      { 'string': '[%{statusline#extensions#netrw#order()}] ' },
\    ],
\    'highlight': 2,
\    'condition': '&ft=="netrw"',
\  },
\  {
\    'list': [
\      { 'string': ' %{&fileformat} ' },
\      { 'string': '[%{statusline#core#encoding()}] ' },
\    ],
\    'highlight': 2,
\    'condition': '&ft!="netrw"',
\    'truncate': 80,
\  },
\  {
\    'list': [
\      { 'string': ' %P ', 'width': '4' },
\      { 'string': '%l', 'width': '4' },
\      { 'string': ':' },
\      { 'string': '%c%V ', 'width': '-4' },
\    ],
\    'highlight': 1,
\    'truncate': 60,
\  },
\  {
\    'string': ' %{SyntasticStatuslineFlag()} ',
\    'highlight': 'WarningMsg',
\    'condition': 'get(g:, "loaded_syntastic_plugin", 0)',
\  },
\]

function statusline#templates#flatline#load()
  return s:template
endfunction
