"basics
syntax on
filetype on
filetype plugin on
filetype indent on
set nocompatible
set nu rnu
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab
set incsearch
set ignorecase
set smartcase
set showcmd
set showmode
set history=1000
set number
set linebreak
"set mouse=a
"set paste
set autoindent

"leader key
let mapleader=","
nnoremap <leader>t :terminal<CR>

"KEY MAPPINGS
nmap l cl
xnoremap l cl
nmap s <Right>
xnoremap s <Right>
nnoremap <C-L> :nohl<CR><C-L>

"SPELL CHECK
set spell spelllang=en
set spellcapcheck=
hi SpellBad ctermbg=1

"LINE WRAP
set wrap
set wrapmargin=0
set textwidth=0
set breakindent
set breakindentopt=shift:2

"HIGHLIGHTS
set hlsearch
set showmatch
hi Search cterm=NONE ctermfg=black ctermbg=darkgreen
hi SpellBad cterm=NONE ctermfg=yellow ctermbg=darkred
hi MatchParen cterm=BOLD ctermfg=black ctermbg=darkgreen

" cursorline highlighting
set cursorline
"hi CursorLine cterm=NONE ctermbg=22 ctermfg=15
"hi CursorLineNr term=bold cterm=NONE ctermbg=22 ctermfg=15
" figure out keyboard shortcut for toggling cursorline

"custom highlighting
hi question ctermfg=darkblue
hi note ctermfg=darkgreen
hi reference ctermfg=yellow
hi warning ctermfg=darkred
hi Comment ctermfg=yellow
augroup CustomHighlights
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * syntax match question  /.*??.*/
  autocmd VimEnter,WinEnter,BufWinEnter * syntax match note      /.*##.*/
  autocmd VimEnter,WinEnter,BufWinEnter * syntax match reference /.*<<.*/
  autocmd VimEnter,WinEnter,BufWinEnter * syntax match warning   /.*!!.*/
augroup END

"MISC
"racket specifics
augroup racket_specifics
  autocmd!
  autocmd FileType racket setlocal nocursorline
  autocmd filetype lisp,scheme,art,racket setlocal equalprg=scmindent.rkt
  "figure out disabling paren default paren highlighting for racket files
augroup END

"disable auto comment globally
augroup NoAutoComment
  autocmd!
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

"open file with cursor at last location
augroup RestoreCursor
  autocmd!
  autocmd BufReadPost *
    \ let line = line("'\"")
    \ | if line >= 1 && line <= line("$") && &filetype !~# 'commit'
    \      && index(['xxd', 'gitrebase'], &filetype) == -1
    \      && !&diff
    \ |   execute "normal! g`\""
    \ | endif
augroup END
