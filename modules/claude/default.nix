{ pkgs, ... }:

{
  home = {
    packages = [
      pkgs.fd # modern find
      pkgs.ripgrep # modern grep (rg)
      pkgs.bat # modern cat
      pkgs.hyperfine # command-line benchmarking tool
      pkgs.tokei # displays statistics about code
      pkgs.uv # fast Python package manager
      pkgs.dogdns # modern dig (DNS client)
      pkgs.tealdeer # fast tldr client for command examples
      pkgs.ast-grep
      pkgs.sd
      pkgs.terminal-notifier
    ];

    file = {
      ".claude/CLAUDE.md".text = builtins.readFile ./CLAUDE.md;

      # Copy all command files to ~/.claude/commands/
      ".claude/commands" = {
        source = ./commands;
        recursive = true;
      };

      # Claude Code hooks configuration
      ".claude/settings.json".text = builtins.readFile ./settings.json;
    };

    sessionVariables = {
      DISABLE_ERROR_REPORTING = "1";
      DISABLE_TELEMETRY = "1";
      DISABLE_BUG_COMMAND = "1";
    };
  };
}
