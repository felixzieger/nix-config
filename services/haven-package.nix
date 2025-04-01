{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "haven";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "bitvora";
    repo = "haven";
    rev = "v${version}";
    sha256 = "sha256-rSycrHW53TgqbsfgaRn3492EWtpu440GtbegozqnzMQ=";
  };

  vendorHash = "sha256-5d6C2sNG8aCaC+z+hyLgOiEPWP/NmAcRRbRVC4KuCEw=";

  postInstall = ''
    mkdir -p $out/share/haven
    cp -r $src/templates $out/share/haven/
    cp $src/.env.example $out/share/haven/.env.example
  '';

  meta = with lib; {
    description = "High Availability Vault for Events on Nostr";
    homepage = "https://github.com/bitvora/haven";
    changelog = "https://github.com/bitvora/haven/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ felixzieger ];
    mainProgram = "haven";
  };
}
