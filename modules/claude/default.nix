{ pkgs, unstable, ... }:

{
  home.packages = with pkgs; [
    unstable.claude-code
    fd # modern find
    ripgrep # modern grep (rg)
    bat # modern cat
    pnpm # modern npm
    hyperfine # command-line benchmarking tool
    tokei # displays statistics about code
    oxlint # linter for JavaScript and TypeScript
    uv # fast Python package manager
    dogdns # modern dig (DNS client)
    tealdeer # fast tldr client for command examples
  ];

  home.file.".claude/CLAUDE.md".text = builtins.readFile ./CLAUDE.md;
}

