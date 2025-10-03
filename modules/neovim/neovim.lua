pcall(function()
  vim.loader.enable()
end)

vim.cmd('syntax on')
pcall(vim.cmd.colorscheme, 'bluloco')

local opt = vim.opt
opt.termguicolors = true
opt.tabstop = 8
opt.softtabstop = 0
opt.expandtab = true
opt.shiftwidth = 4
opt.smarttab = true
opt.scrolloff = 6
opt.mouse = 'a'
opt.mousescroll = 'ver:3,hor:0'
opt.wrap = false
opt.ignorecase = true
opt.smartcase = true
opt.autoread = true

vim.g.mapleader = ' '

local map = vim.keymap.set

-- Disable arrow keys outside of insert to encourage hjkl usage
map({'n', 'v', 'o'}, '<Up>', '<Nop>')
map({'n', 'v', 'o'}, '<Down>', '<Nop>')
map({'n', 'v', 'o'}, '<Left>', '<Nop>')
map({'n', 'v', 'o'}, '<Right>', '<Nop>')

-- Window navigation
map('n', '<leader>h', '<C-w>h', { desc = 'Focus left window' })
map('n', '<leader>j', '<C-w>j', { desc = 'Focus lower window' })
map('n', '<leader>k', '<C-w>k', { desc = 'Focus upper window' })
map('n', '<leader>l', '<C-w>l', { desc = 'Focus right window' })

-- FzfLua
map('n', '<leader>f', '<cmd>FzfLua files<CR>', { desc = 'Find file' })
map('n', '<leader>r', '<cmd>FzfLua live_grep<CR>', { desc = 'Live ripgrep' })
map('n', '<leader>b', '<cmd>FzfLua buffers<CR>', { desc = 'Switch buffer' })
map('n', '<leader>s', '<cmd>FzfLua lsp_document_symbols<CR>', { desc = 'Document symbols' })

-- File explorers
map('n', '<leader>n', '<cmd>NvimTreeFindFileToggle<CR>', { desc = 'Toggle file tree' })

-- Buffer navigation & clipboard helpers
map('n', '<leader><leader>', '<cmd>e#<CR>', { desc = 'Previous buffer' })
map('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })
map('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
map('n', '<leader>w', '<cmd>w<CR>', { desc = 'Write buffer' })

-- Toggle line numbers
map('n', '<leader>tl', function()
  vim.cmd('set number!')
end, { desc = 'Toggle line numbers' })

-- Disable netrw in favour of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
