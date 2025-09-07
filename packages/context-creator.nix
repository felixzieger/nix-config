{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "context-creator";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "matiasvillaverde";
    repo = "context-creator";
    rev = "v${version}";
    hash = "";
  };

  # Project doesn't include Cargo.lock, so we provide one
  cargoLock = {
    lockFile = ./context-creator-Cargo.lock;
  };

  postPatch = ''
    ln -s ${./context-creator-Cargo.lock} Cargo.lock
  '';

  checkFlags = [
    # Clipboard tests fail in sandbox environment
    "--skip=test_clipboard_copy"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = "High-performance CLI tool to convert codebases to Markdown for LLM context";
    homepage = "https://github.com/matiasvillaverde/context-creator";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "context-creator";
  };
}
