_: {
  # programs.ghostty is broken on darwin as of 2025-07-22
  # Using home.file instead to manage the config

  home.file.".config/ghostty/config".text = ''
    macos-titlebar-style = native
    keybind = shift+enter=text:\n

    # Split navigation with CMD+vim style keys
    keybind = cmd+k=goto_split:up
    keybind = cmd+j=goto_split:down
    keybind = cmd+h=goto_split:left
    keybind = cmd+l=goto_split:right
  '';
}
