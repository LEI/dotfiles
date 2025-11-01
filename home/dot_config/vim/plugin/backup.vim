" Persistent undo history
let home = expand('$HOME')
let dir = home . '/.local/share/vim'
let backupdir = dir . '/backup//'
let swapdir = dir . '/swap//'
let undodir = dir . '/undo//'

if !isdirectory(backupdir)
  call mkdir(backupdir, 'p', '0o700')
endif

let &backupdir = backupdir
let &directory = swapdir
let &undodir = undodir

set backup
set noswapfile
if has('persistent_undo')
  set undofile " Keep undo changes after closing
endif
