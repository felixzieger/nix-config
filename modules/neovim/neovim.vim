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

let mapleader=" "

" Move between windows
nnoremap <leader>h <C-W>h
nnoremap <leader>j <C-W>j
nnoremap <leader>k <C-W>k
nnoremap <leader>l <C-W>l

" Telescope
nnoremap <leader>f <cmd>Telescope find_files<cr>
nnoremap <leader>r <cmd>Telescope live_grep<cr>
nnoremap <leader>b <cmd>Telescope buffers<cr>

map <leader>n :NvimTreeFindFileToggle<CR>

" Switch to last buffer
map <leader><leader> :e#<CR>
" Copy paste from system clipboard
vmap <leader>y "+y
nmap <leader>p "+p
" Safe file
nmap <leader>w :w<CR>

" Toggle line numbers
nmap <leader>tl :set number!<CR>
