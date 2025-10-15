-- ToggleTerm configuration
require("toggleterm").setup{
  size = 20,
  open_mapping = [[<c-`>]],
  hide_numbers = true,
  shade_terminals = true,
  shading_factor = -30,
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  persist_size = true,
  persist_mode = true,
  direction = 'float',
  close_on_exit = true,
  shell = vim.o.shell,
  auto_scroll = true,
  float_opts = {
    border = 'curved',
    width = function()
      return math.floor(vim.o.columns * 0.9)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.9)
    end,
    winblend = 0,
  },
}

-- Terminal window mappings for easier navigation
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  -- Don't map ESC for lazygit and other TUI apps that need it
  -- vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- Apply terminal keymaps when opening terminals
vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

-- Custom lazygit terminal
local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "curved",
    width = function()
      return math.floor(vim.o.columns * 0.9)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.9)
    end,
    winblend = 0,
  },
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

function _lazygit_toggle()
  lazygit:toggle()
end

-- Custom scooter terminal
local scooter = Terminal:new({
  cmd = "scooter",
  direction = "float",
  float_opts = {
    border = "curved",
    width = function()
      return math.floor(vim.o.columns * 0.9)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.9)
    end,
    winblend = 0,
  },
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

function _scooter_toggle()
  scooter:toggle()
end

-- Custom btop terminal
local btop = Terminal:new({
  cmd = "btop",
  direction = "float",
  float_opts = {
    border = "curved",
    width = function()
      return math.floor(vim.o.columns * 0.9)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.9)
    end,
    winblend = 0,
  },
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

function _btop_toggle()
  btop:toggle()
end

-- Keybindings
vim.keymap.set('n', '<leader>gg', '<cmd>lua _lazygit_toggle()<CR>', { noremap = true, silent = true, desc = "Open LazyGit in floating terminal" })
vim.keymap.set('n', '<leader>gs', '<cmd>lua _scooter_toggle()<CR>', { noremap = true, silent = true, desc = "Open Scooter in floating terminal" })
vim.keymap.set('n', '<leader>gb', '<cmd>lua _btop_toggle()<CR>', { noremap = true, silent = true, desc = "Open btop in floating terminal" })
