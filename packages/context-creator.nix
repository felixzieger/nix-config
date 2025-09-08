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
    hash = "sha256-NHBSEoPlqBThyxFBjXMPqOwe/IQBodNKtbH9Jn/2rnw=";
  };

  # Project doesn't include Cargo.lock, so we provide one
  cargoLock = {
    lockFile = ./context-creator-Cargo.lock;
  };

  postPatch = ''
    ln -s ${./context-creator-Cargo.lock} Cargo.lock
  '';

  doCheck = false;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  OPENSSL_NO_VENDOR = 1;

  meta = with lib; {
    description = "High-performance CLI tool to convert codebases to Markdown for LLM context";
    homepage = "https://github.com/matiasvillaverde/context-creator";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "context-creator";
  };
}
