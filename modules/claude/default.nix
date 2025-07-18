{ pkgs, unstable, ... }:

{
  home.packages = with pkgs; [

    unstable.claude-code # From nixpkgs

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
    code-digest
    sd
    terminal-notifier
  ];

  home.file = {
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
}
