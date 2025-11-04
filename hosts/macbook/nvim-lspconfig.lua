local lspconfig = require('lspconfig')
local util = require('lspconfig.util')

local function file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat and stat.type == 'file'
end

local function deno_root_dir(fname)
  -- First prefer an explicit deno.json/deno.jsonc in the ancestor tree
  local root = util.root_pattern('deno.json', 'deno.jsonc')(fname)
  if root then
    return root
  end

  -- Supabase functions keep their own config inside supabase/functions/<name>/
  local function_root = fname:match('(.*supabase/functions/[^/]+)')
  if function_root and file_exists(util.path.join(function_root, 'deno.json')) then
    return function_root
  end
end

-- Blink provides LSP capabilities directly
local capabilities = require('blink.cmp').get_lsp_capabilities()
lspconfig.html.setup { capabilities = capabilities }
lspconfig.bashls.setup { capabilities = capabilities }
lspconfig.yamlls.setup { capabilities = capabilities }
lspconfig.jsonls.setup { capabilities = capabilities }
-- lspconfig.terraformls.setup { capabilities = capabilities }
lspconfig.rust_analyzer.setup { capabilities = capabilities }

-- TypeScript/JavaScript configuration with Deno support
lspconfig.denols.setup {
  capabilities = capabilities,
  root_dir = deno_root_dir,
  single_file_support = false,
}

lspconfig.ts_ls.setup {
  capabilities = capabilities,
  -- For monorepos: Look for tsconfig.app.json (Vite projects) or tsconfig.json
  -- This ensures path mappings from tsconfig.app.json are picked up
  root_dir = function(fname)
    -- Skip starting tsserver inside Supabase function roots so Deno can handle them
    if deno_root_dir(fname) then
      return nil
    end
    -- First try to find tsconfig.app.json (Vite/project references setup)
    local app_config_root = util.root_pattern("tsconfig.app.json")(fname)
    if app_config_root then
      return app_config_root
    end
    -- Fall back to tsconfig.json or package.json
    return util.root_pattern("tsconfig.json", "package.json")(fname)
  end,
  single_file_support = false,
  on_attach = function(client, bufnr)
    -- Check if current buffer is in a Deno project
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local deno_root = deno_root_dir(fname)

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
          },
          Lua = {
            diagnostics = {
              globals = { 'vim' },
            },
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

    vim.keymap.set('n', '<leader>gR', vim.lsp.buf.rename, opts) -- Makes <leader>r slow to appear
    vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, opts)
  end
})

-- Python LSP setup
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

-- Ruff LSP: diagnostics only
lspconfig.ruff.setup {
  capabilities = capabilities,
  cmd = { "ruff", "server", "--preview" },
  init_options = {
    settings = {
      interpreter = { find_python_executable() }
    }
  },
  on_attach = function(client, bufnr)
    -- Disable all LSP features except diagnostics
    client.server_capabilities.hoverProvider = false
    client.server_capabilities.definitionProvider = false
    client.server_capabilities.implementationProvider = false
    client.server_capabilities.referencesProvider = false
    client.server_capabilities.renameProvider = false
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.documentSymbolProvider = false
    client.server_capabilities.documentFormattingProvider = false
  end
}

-- Pyright LSP: full Python support
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
