"incompatible with vi
set nocompatible

"netrw
let g:netrw_browse_split =0 
let g:netrw_winsize = 25
let g:netrw_banner = 0
let g:netrw_altv = 1
let g:netrw_list_hide = &wildignore

syntax on

"line numbers on
set number

"tabs show as 2 spaces, rather then 8
set tabstop=2
set shiftwidth=2
set expandtab

"reload files changed outside vim
set autoread

"utf-8 encoding
set encoding=utf-8
set fileencoding=utf-8

"windows clipboard copy
"yank, put with clipboard without requiring "*
let &clipboard = has('unnamedplus') ? 'unnamedplus' : 'unnamed'

"map c-x and c-v to work as they do in windows, only in insert mode
vm <c-x> "+x
vm <c-c> "+y
cno <c-v> <c-r>+
exe 'ino <script> <C-V>' paste#paste_cmd['i']

"save with ctrl+s
nmap <c-s> :w<CR>
imap <c-s> <Esc>:w<CR>a

"buftabline
set hidden
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprev<CR>

"Backspace default updates
set backspace=indent,eol,start

colorscheme murphy
