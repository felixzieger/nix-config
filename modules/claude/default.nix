{ pkgs, unstable, ... }:

{
  home = {
    packages = [

      unstable.claude-code # From nixpkgs

      pkgs.fd # modern find
      pkgs.ripgrep # modern grep (rg)
      pkgs.bat # modern cat
      pkgs.pnpm # modern npm
      pkgs.hyperfine # command-line benchmarking tool
      pkgs.tokei # displays statistics about code
      pkgs.oxlint # linter for JavaScript and TypeScript
      pkgs.uv # fast Python package manager
      pkgs.dogdns # modern dig (DNS client)
      pkgs.tealdeer # fast tldr client for command examples
      pkgs.code-digest
      pkgs.sd
      pkgs.terminal-notifier
    ];
    sessionVariables = {
      CLAUDE_CODE_MAX_OUTPUT_TOKENS = "360000";
    };

    file = {
      ".claude/CLAUDE.md".text = builtins.readFile ./CLAUDE.md;

      # Copy all command files to ~/.claude/commands/
      ".claude/commands" = {
        source = ./commands;
        recursive = true;
      };

      # Claude Code hooks configuration
      ".claude/settings.json".text = builtins.toJSON {
        hooks = {
          Stop = [
            {
              matcher = ".*";
              hooks = [
                {
                  type = "command";
                  command = ''${pkgs.terminal-notifier}/bin/terminal-notifier -title "Claude Code" -message "Task completed" -sound default -appIcon "${./claude.png}"'';
                }
              ];
            }
          ];
        };
      };
    };
  };
}
