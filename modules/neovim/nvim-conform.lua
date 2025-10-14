require("conform").setup({
  --  for users who want auto-save conform + lazyloading!
  event = 'BufWritePre',
  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters_by_ft = {
    nix = { 'nixfmt' },
    python = { 'ruff_format' },

    -- Fix common misspellings in source code on all filetypes
    -- ['*'] = { 'codespell' },
  },
})
