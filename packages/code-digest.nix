{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "code-digest";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "matiasvillaverde";
    repo = "code-digest";
    rev = "v${version}";
    hash = "sha256-GKbVyIfH2QJD4T2MBWmb3++/V2u8JaWN0SGPc5mV9iU=";
  };

  # Project doesn't include Cargo.lock, so we provide one
  cargoLock = {
    lockFile = ./code-digest-Cargo.lock;
  };

  postPatch = ''
    ln -s ${./code-digest-Cargo.lock} Cargo.lock
  '';

  checkFlags = [
    # Clipboard tests fail in sandbox environment
    "--skip=test_clipboard_copy"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "High-performance CLI tool to convert codebases to Markdown for LLM context";
    homepage = "https://github.com/matiasvillaverde/code-digest";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "code-digest";
  };
}
