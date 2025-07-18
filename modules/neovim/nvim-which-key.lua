local wk = require("which-key")

wk.setup {}

-- Register LSP keybindings with descriptions
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('WhichKeyLspConfig', {}),
  callback = function(ev)
    wk.add({
      { "<leader>g", buffer = ev.buf, group = "LSP/Go to" },
      { "<leader>gh", buffer = ev.buf, desc = "Hover" },
      { "<leader>gj", buffer = ev.buf, desc = "Signature Help" },
      { "<leader>gi", buffer = ev.buf, desc = "Implementation" },
      { "<leader>gd", buffer = ev.buf, desc = "Type Definition" },
      { "<leader>gf", buffer = ev.buf, desc = "Declaration" },
      { "<leader>gg", buffer = ev.buf, desc = "Definition" },
      { "<leader>gr", buffer = ev.buf, desc = "References" },
    })
  end
})
