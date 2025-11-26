_: {
  home = {
    file = {
      ".config/amp/settings.json".text = builtins.readFile ./settings.json;
    };
  };
}
