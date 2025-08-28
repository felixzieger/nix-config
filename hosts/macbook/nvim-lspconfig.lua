local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
lspconfig.html.setup { capabilities = capabilities }
lspconfig.bashls.setup { capabilities = capabilities }
lspconfig.yamlls.setup { capabilities = capabilities }
lspconfig.jsonls.setup { capabilities = capabilities }
lspconfig.terraformls.setup { capabilities = capabilities }
lspconfig.rust_analyzer.setup { capabilities = capabilities }

-- TypeScript/JavaScript configuration with Deno support
lspconfig.denols.setup {
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
}

lspconfig.ts_ls.setup {
  capabilities = capabilities,
  root_dir = lspconfig.util.root_pattern("package.json"),
  single_file_support = false,
  on_attach = function(client, bufnr)
    -- Check if current buffer is in a Deno project
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local deno_root = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(fname)

    if deno_root then
      -- Detach ts_ls from this buffer if it's in a Deno project
      vim.lsp.stop_client(client.id, true)
    end
  end
}

lspconfig.nil_ls.setup {
  capabilities = capabilities,
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixfmt" },
      },
    },
  },
}
lspconfig.lua_ls.setup {
  capabilities = capabilities,
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
            }
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', '<leader>gh', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>gj', vim.lsp.buf.signature_help, opts)

    vim.keymap.set('n', '<leader>gi', '<cmd>FzfLua lsp_implementations<cr>', opts)
    vim.keymap.set('n', '<leader>gD', '<cmd>FzfLua lsp_typedefs<cr>', opts)
    vim.keymap.set('n', '<leader>gf', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>gd', '<cmd>FzfLua lsp_definitions<cr>', opts)
    vim.keymap.set('n', '<leader>gr', '<cmd>FzfLua lsp_references<cr>', opts)

    -- vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts) -- Makes <leader>r slow to appear
    vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, opts)
  end
})

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
