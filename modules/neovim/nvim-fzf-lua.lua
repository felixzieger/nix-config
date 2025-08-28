require('fzf-lua').setup {
  winopts = {
    height = 0.85,
    width = 0.80,
    row = 0.35,
    col = 0.50,
    preview = {
      default = 'bat',
      vertical = 'down:45%',
      horizontal = 'right:50%',
    },
  },
  keymap = {
    builtin = {
      ["<C-d>"] = "preview-page-down",
      ["<C-u>"] = "preview-page-up",
    },
    fzf = {
      ["ctrl-d"] = "preview-page-down",
      ["ctrl-u"] = "preview-page-up",
    },
  },
  files = {
    prompt = 'Files> ',
    cmd = 'fd --type f --hidden --follow --exclude .git',
    actions = {
      ["default"] = require('fzf-lua').actions.file_edit,
    },
  },
  grep = {
    prompt = 'Rg> ',
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden",
    actions = {
      ["default"] = require('fzf-lua').actions.file_edit,
    },
  },
  buffers = {
    prompt = 'Buffers> ',
    actions = {
      ["default"] = require('fzf-lua').actions.buf_edit,
    },
  },
  lsp = {
    prompt_postfix = '> ',
    symbols = {
      prompt = 'Symbols> ',
    },
  },
}