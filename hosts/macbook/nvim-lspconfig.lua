local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.terraformls.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.ts_ls.setup { capabilities = capabilities } -- typescript
lspconfig.rust_analyzer.setup { capabilities = capabilities }

-- python
lspconfig.ruff.setup { capabilities = capabilities }
lspconfig.pyright.setup { capabilities = capabilities }

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == 'ruff' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = 'LSP: Disable hover capability from Ruff',
})

