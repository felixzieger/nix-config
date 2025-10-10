# Tool Preferences

The following tools are available:

- Use `hyperfine` for benchmarking command-line programs
- Use `tokei` for counting lines of code and getting code statistics
- Use `context-creator --prompt '<Your question here>'` to consult other AI models
- Use `ast-grep` for searching code

When not specified otherwise, default on using these tools:

- Use `pnpm` instead of `npm`
- Use `uv` instead of `pip`
- Use `oxlint` for linting JavaScript and TypeScript code

To understand how programs work
- Pass the `--help` flag to CLI programs
- Use `tldr` for getting command examples
- Use context7 MCP for fetching up-to-date documentation of APIs and libraries we use

Devenv is used for managing development environments.
- When devenv.nix doesn't exist and a command/tool is missing, create ad-hoc environment:
`devenv -O languages.rust.enable:bool true -O packages:pkgs "mypackage mypackage2" shell -- cli args` (https://devenv.sh/ad-hoc-developer-environments/)
- When the setup is becomes complex create `devenv.nix` and run commands within:
`devenv shell -- cli args`

