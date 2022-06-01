{ config, pkgs, ... }:

# For setup I followed
# https://wickedchicken.github.io/post/macos-nix-setup/

# Inspiration
# https://github.com/a-h/dotfiles/blob/master/.nixpkgs/darwin-configuration.nix
# https://github.com/kubukoz/nix-config
# https://www.nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html
# https://markhudnall.com/2021/01/27/first-impressions-of-nix/

# Search packages at https://search.nixos.org/packages


# Home manager <-> nix-darwin integration
# https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module


# Configuration collection
# AWESOME: https://github.com/biosan/dotfiles
# Has LOGITECH and other brew stuff as file: https://github.com/biosan/dotfiles/blob/master/config/macos/Brewfile
# https://nixos.wiki/wiki/Configuration_Collection

{
  imports = [ <home-manager/nix-darwin> ];
  
  home-manager.useGlobalPkgs = true;

  users.users.fzieger = {
  name = "fzieger";
  home = "/Users/fzieger";
  shell = pkgs.zsh;
  };

  users.users.xilef = {
  name = "xilef";
  home = "/Users/xilef";
  shell = pkgs.zsh;
  };
  home-manager.users.fzieger = { pkgs, ... }: {
    home.packages = [
      pkgs.kubectl
    ];
  };
  home-manager.users.xilef = { pkgs, ... }: {
    home.packages = [
      pkgs.python39
      pkgs.python39Packages.tkinter
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.variables = { EDITOR = "vim"; };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.oh-my-zsh
      pkgs.zsh-z
      pkgs.git
      pkgs.fzf # add ZSH shortcuts by following https://nixos.wiki/wiki/Fzf
      pkgs.lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199#issuecomment-494218334
      pkgs.nerdfonts
      pkgs.pass
      pkgs.tree
      pkgs.silver-searcher
      pkgs.starship
      pkgs.fly
      # pkgs.dhall # todo: fix version
      # pkgs.dhall-lsp-server
      # pkgs.dhall-json
      pkgs.terraform
      pkgs.terraform-lsp
      pkgs.rnix-lsp
      pkgs.wget
      pkgs.k9s
      pkgs.nodejs
      pkgs.tmux
      pkgs.mycli
      pkgs.vault
      pkgs.jq
      pkgs.yarn
      pkgs.kotlin
      pkgs.jdk
      pkgs.google-cloud-sdk
      # pkgs.azure-cli
      # pkgs.awscli2
      pkgs.vscode
      pkgs.deno
      pkgs.parallel
      # Still making problems...
      # pkgs.firefox # maybe https://github.com/cmacrae/config/tree/b33ccb041861b56c97e1744b0fd8c606e343164c/overlays/firefox
      # pkgs.slack # hash mismatch
      # pkgs.autoconf # needed for idea-community as of 2021-11-13?
      # pkgs.jetbrains.idea-community
      # pkgs.keepassxc # Install went through but did not show up when I wanted to use it. 
      # pkgs.iterm2 # Code signing stuff
      #
      # Linux support
      # pkgs.flameshot # https://github.com/flameshot-org/flameshot
      # pkgs.nextcloud-client
      # pkgs.teams
      # pkgs.sublime-merge
      # pkgs.zoom-us
      # pkgs.spotify
      #
      # Find out how to install
      # https://github.com/rxhanson/Rectangle
      # Alfred
      # Alfred can show applciations installed via nix. See https://markhudnall.com/2021/01/27/first-impressions-of-nix/
      #
      #From https://github.com/a-h/dotfiles/blob/master/.nixpkgs/darwin-configuration.nix
      (
        pkgs.neovim.override {
          vimAlias = true;
          configure = {
            packages.myPlugins = with pkgs.vimPlugins; {
              start = [
                fzf-vim
                vim-commentary # https://github.com/tpope/vim-commentary TLDR: gcc for quick un/commenting
                bufferline-nvim
                nvim-lspconfig
                vim-nix
                kotlin-vim
                dhall-vim
                ansible-vim
                vim-terraform # Alternative would be vim-terraform-completion
              ];
              opt = [ ];
            };
            customRC = ''
              set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab
              set scrolloff=6

              " activate bufferline plugin
              set termguicolors
              lua << EOF
              require("bufferline").setup{}
              EOF

              " activate LSP (followed https://neovim.io/doc/user/lsp.html)
              lua << EOF
              -- Mappings.
              -- See `:help vim.diagnostic.*` for documentation on any of the below functions
              local opts = { noremap=true, silent=true }
              vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
              -- vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
              -- vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
              -- vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
              
              -- Use an on_attach function to only map the following keys
              -- after the language server attaches to the current buffer
              local on_attach = function(client, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
              
                -- Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
                -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
                vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
              end
              
              -- Use a loop to conveniently call 'setup' on multiple servers and
              -- map buffer local keybindings when the language server attaches
              local servers = { 'dhall_lsp_server', 'terraform_lsp', 'yamlls', 'jsonls', 'rnix'}
              for _, lsp in pairs(servers) do
                require('lspconfig')[lsp].setup {
                  on_attach = on_attach,
                  flags = {
                    -- This will be the default in neovim 0.7+
                    debounce_text_changes = 150,
                  }
                }
              end
              EOF
            '';
          };
        }
      )
    ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  programs.zsh = {
    enable = true;
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [ "git" "thefuck" ];
    #   theme = "robbyrussell";
    # };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
