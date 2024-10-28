local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.terraformls.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.pyright.setup { capabilities = capabilities }
lspconfig.ruff_lsp.setup { capabilities = capabilities }
