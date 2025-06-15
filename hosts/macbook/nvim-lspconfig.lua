local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.terraformls.setup { capabilities = capabilities }
lspconfig.html.setup { capabilities = capabilities }
lspconfig.ts_ls.setup { capabilities = capabilities } -- typescript
lspconfig.rust_analyzer.setup { capabilities = capabilities }

-- python
local function find_python_executable()
  local current_dir = vim.fn.getcwd()
  
  -- Check for uv project (.venv/bin/python)
  local uv_python = current_dir .. "/.venv/bin/python"
  if vim.fn.executable(uv_python) == 1 then
    return uv_python
  end
  
  -- Check for standard venv
  local venv_python = current_dir .. "/venv/bin/python"
  if vim.fn.executable(venv_python) == 1 then
    return venv_python
  end
  
  -- Fall back to system python
  return "python3"
end

lspconfig.ruff.setup { 
  capabilities = capabilities,
  cmd = { "ruff", "server", "--preview" },
  init_options = {
    settings = {
      interpreter = { find_python_executable() }
    }
  }
}

lspconfig.pyright.setup { 
  capabilities = capabilities,
  settings = {
    python = {
      pythonPath = find_python_executable(),
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace"
      }
    }
  }
}

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

