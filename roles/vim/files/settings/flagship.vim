" Vim Flagship

if !exists('g:loaded_flagship')
  finish
endif

" set laststatus=2
" set showtabline=2
" set guioptions-=e

set showtabline=1

" set statusline=%n\ %f
let &g:statusline = '[%n]%< %f '
let &rulerformat = '%-14.(%l,%c%V/%L%) %P '

let g:flagship_skip = 'fugitive#statusline' "\|flagship#filetype'
autocmd User Flags call Hoist('buffer', {'hl': 'StatusLineNC'}, '%( %{fugitive#head(7)} %)', )
autocmd User Flags call Hoist('buffer', function('SyntasticStatuslineFlag'))
