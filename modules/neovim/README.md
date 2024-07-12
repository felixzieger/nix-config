neovim 0.10

- `gx` in Normal mode calls `vim.ui.open()` on whatever is under the cursor, which shells out to your operating system’s “open” capability (e.g. `open` on macOS or `xdg-open` on Linux). For instance, pressing `gx` on a URL will open that URL in your browser.
- LSP inlay hints
    
    Nvim 0.10 now supports LSP inlay hints thanks to Chinmay Dalal. A picture here will do more than my words can:
    
    The dark colored texts which display type annotations for variable declarations are inlay hints. This text is not part of the actual source file in the buffer, but is “virtual” text inserted by Nvim and provided by the language server. These hints can be enabled or disabled dynamically using `vim.lsp.inlay_hint.enable()`.
    
- Nvim 0.10 adds a new [default mapping](https://github.com/neovim/neovim/pull/24331): `K` in Normal mode maps to `vim.lsp.buf.hover()` . This in addition to the existing defaults mentioned in :h lsp-defaults which were added in the previous release.
