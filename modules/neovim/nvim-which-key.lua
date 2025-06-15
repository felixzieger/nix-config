local wk = require("which-key")

wk.setup {}

-- Register LSP keybindings with descriptions
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('WhichKeyLspConfig', {}),
  callback = function(ev)
    wk.register({
      g = {
        name = "LSP/Go to",
        h = { "Hover" },
        j = { "Signature Help" },
        i = { "Implementation" },
        d = { "Type Definition" },
        f = { "Declaration" },
        g = { "Definition" },
        r = { "References" },
      }
    }, { prefix = "<leader>", buffer = ev.buf })
  end
})
