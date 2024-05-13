colorscheme tokyonight-storm
syntax on
set termguicolors

set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set scrolloff=6
set mouse=a
set mousescroll=ver:3,hor:0 " disable horizonal scrolling
set nowrap
set ignorecase
set smartcase

" No more arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

let mapleader="ö"

" FZF
map <leader>a :FzfLua grep_project<CR>
map <leader>r :FzfLua live_grep<CR>
map <leader>f :FzfLua files<CR>
map <leader>b :FzfLua buffers<CR>
map <leader>g :FzfLua git_commits<CR>


map <leader>n :NvimTreeFindFileToggle<CR>

" Switch to last buffer
map <leader>ö :e#<CR>
" Copy paste from system clipboard
vmap <leader>y "+y
nmap <leader>p "+p
" Safe file
nmap <leader>w :w<CR>
" Toggle line numbers
nmap <leader>l :set number!<CR>

