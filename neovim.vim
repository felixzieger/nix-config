set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
set scrolloff=6
set mouse=a
set nowrap
set ignorecase
set smartcase

" No more arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

let mapleader="ö"

" Keep Ag around, because live_grep does not fuzzy search.
" Look into https://github.com/kelly-lin/telescope-ag
map <leader>a :Ag<CR>
" map <leader>f :FZF<CR>
map <leader>f :Files<CR>
map <leader>b :Buffers<CR>
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fa <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

let minimap_highlight_range=1
let minimap_highlight_search=1
nmap <leader>m :MinimapToggle<CR>

map <leader>n :NvimTreeFindFileToggle<CR>

let g:EasyMotion_do_mapping = 0
map <Leader> <Plug>(easymotion-prefix)
let g:EasyMotion_smartcase = 1
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>s <Plug>(easymotion-s)
map <Leader>w <Plug>(easymotion-w)
map <Leader>W <Plug>(easymotion-W)
map <Leader>b <Plug>(easymotion-b)
map <Leader>B <Plug>(easymotion-B)


" Switch to last buffer
map <leader>ö :e#<CR>
" Copy paste from system clipboard
vmap <leader>y "+y
nmap <leader>p "+p
" Safe file
nmap <leader><leader>w :w<CR>
" Toggle line numbers
nmap <leader>l :set number!<CR>

lua << EOF
-- activate LSP (followed https://neovim.io/doc/user/lsp.html)
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
-- vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
-- vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
-- vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'dhall_lsp_server', 'denols', 'terraformls', 'yamlls', 'jsonls', 'rnix', 'bashls' }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach
  }
end

-- highlighting codefences for deno requires the following
vim.g.markdown_fenced_languages = {
  "ts=typescript"
}

-- Activate lualine
vim.g.gitblame_display_virtual_text = 0 -- Disable virtual text
vim.g.gitblame_date_format = '%r'
local git_blame = require('gitblame')

require('lualine').setup({
    options = {
        theme = 'papercolor_light'
    },
    sections = {
            lualine_c = {
                { git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available }
            },
            lualine_x = {'filename'},
    },
})

-- Activate null-ls for usage with vale
require("null-ls").setup({
    sources = {
        require("null-ls").builtins.diagnostics.vale,
    },
})

-- Activate nvim-tree
-- g? opens help
require("nvim-tree").setup({
  renderer = {
    group_empty = true,
    indent_markers = {
        enable = true,
    },
  },
  live_filter = {
    always_show_folders = false,
  },
})

require('telescope').load_extension('fzf')

-- FIX for Telescope/FZF colorscheme since nvim 0.8
-- see https://github.com/nvim-telescope/telescope.nvim/issues/2145
-- see https://neovim.discourse.group/t/how-to-configure-floating-window-colors-highlighting-in-0-8/3193/2

vim.api.nvim_set_hl(0, 'FloatBorder', {bg='#3B4252', fg='#5E81AC'})
vim.api.nvim_set_hl(0, 'NormalFloat', {bg='#3B4252'})
vim.api.nvim_set_hl(0, 'TelescopeNormal', {bg='#3B4252'})
vim.api.nvim_set_hl(0, 'TelescopeBorder', {bg='#3B4252'})
EOF
