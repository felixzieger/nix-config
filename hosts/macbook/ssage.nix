# can be built with nix-build
# binary can be run with ./result/bin/shell_sage
{
  pkgs ? import <nixpkgs> { },
}:

let
  nbdev_pkg = pkgs.python3Packages.nbdev;

in
pkgs.python3Packages.buildPythonApplication {
  pname = "shell_sage";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "AnswerDotAI";
    repo = "shell_sage";
    rev = "80fb2afde8c507079ca0b0faec0951c99eb3d70d";
    sha256 = "sha256-I7CWGU06kP5p8KCe6A+Syy1ZUssjjI0V+9cE3+Oro5g";
  };

  buildInputs = [
    # Keep this empty for now, as pip install --target will put them into site-packages.
  ];

  nativeBuildInputs = [
    nbdev_pkg
    pkgs.python3Packages.fastcore
    pkgs.python3Packages.jupyter_core
    pkgs.python3Packages.pip # Ensure pip is available
  ];

  preBuild = ''
    echo "Running nbdev_export..."
    ${nbdev_pkg}/bin/nbdev_export
    echo "nbdev_export completed."
  '';

  dontUsePip = true;

  installPhase = ''
    echo "Running explicit pip install for dependencies and package..."
    export PATH=$PATH:${pkgs.python3Packages.pip}/bin

    # --- ADD CLAUDETTE HERE ---
    ${pkgs.python3Packages.pip}/bin/pip install \
      anthropic \
      rich \
      black \
      openai \
      python-dotenv \
      "psutil<6.0.0" \
      "packaging>=23.0" \
      fastcore \
      msglm \
      claudette \
      cosette \
      fastlite \
      --target=$out/${pkgs.python3.sitePackages}

    ${pkgs.python3Packages.pip}/bin/pip install . --no-deps --prefix=$out
    echo "Explicit pip install completed."
  '';
}
