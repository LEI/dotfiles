" Neomake

" Open the loclist or quickfix list when adding entries (default: 0)
" 2: preserve the cursor position when the window is opened
" let g:neomake_open_list = 2

" Height of the list opened by neomake (default: 10)
let g:neomake_list_height = 5

" Echo the error for the line the cursor is on, if any (default: 1)
" let g:neomake_echo_current_error = 0

" let g:neomake_javascript_enabled_makers = ['jshint']
" let g:neomake_javascript_jshint_maker = {
"     \ 'args': ['--verbose'],
"     \ 'errorformat': '%A%f: line %l\, col %v\, %m \(%t%*\d\)',
"     \ }

" let g:neomake_vim_vint_maker = neomake#makers#ft#vim#vint()
" call extend(g:neomake_vim_vint_maker, {
"     \ 'errorformat': '%f:%l:%c:%t%*[^:]:%m'
"     \ }, 'force')

" let g:neomake_error_sign = {
"     \ 'text': 'E>',
"     \ 'texthl': 'ErrorMsg',
"     \ }

augroup NeomakeCheck
  autocmd!
  " BufWinEnter / BufReadPost -> https://github.com/neomake/neomake/issues/408
  " TODO clear loclist on leave
  autocmd BufWritePost * Neomake
  " Hide check message on :wq
  autocmd VimLeave * let g:neomake_verbose = 0
augroup END

" autocmd BufWritePost,BufEnter * call neomake#Make(1, [], function('s:NeomakeCallback'))
" function! s:NeomakeCallback(options)
"   if (a:options.has_next == 0)
"     checktime
"     " echom a:options.name . ' cb'
"     " lwindow
"   endif
" endfunction

" autocmd BufEnter * call EnterNeomake()
" autocmd BufWritePost * call SaveNeomake()
" function! EnterNeomake()
"   " Don't show the location list when entering a buffer
"   let g:neomake_open_list = 0
"   execute 'Neomake'
" endfunction
" function! SaveNeomake()
"   " Show the location list after saving
"   let g:neomake_open_list = 2
"   execute 'Neomake'
" endfunction

" Error file format:

" Basic items:
" %f    file name (finds a string)
" %l    line number (finds a number)
" %c    column number (finds a number representing character
"       column of the error, (1 <tab> == 1 character column))
" %v    virtual column number (finds a number representing
"       screen column of the error (1 <tab> == 8 screen columns))
" %t    error type (finds a single character)
" %n    error number (finds a number)
" %m    error message (finds a string)
" %r    matches the "rest" of a single-line file message %O/P/Q
" %p    pointer line (finds a sequence of '-', '.', ' ' or
"       tabs and uses the length for the column number)
" %*{conv} any scanf non-assignable conversion
" %%    the single '%' character
" %s    search text (finds a string)

" Changing directory
" %D    "enter directory" format string; expects a following
"       %f that finds the directory name
" %X    "leave directory" format string; expects following %f

" Multi-line:
" %E    start of a multi-line error message
" %W    start of a multi-line warning message
" %I    start of a multi-line informational message
" %A    start of a multi-line message (unspecified type)
" %>    for next line start with current pattern again |efm-%>|
" %C    continuation of a multi-line message
" %Z    end of a multi-line message
