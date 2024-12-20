{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "alby-hub";
  version = "0.1.0"; # You'll need to update this with the actual version

  src = fetchurl {
    url = "https://getalby.com/install/hub/server-linux-x86_64.tar.bz2";
    # You'll need to add the hash after downloading the file once
    # Use `nix-prefetch-url https://getalby.com/install/hub/server-linux-x86_64.tar.bz2`
    sha256 = ""; # Add hash here
  };

  nativeBuildInputs = [
    autoPatchelfHook # Automatically fixes dynamic linking
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -D bin/albyhub $out/bin/albyhub

    runHook postInstall
  '';

  meta = with lib; {
    description = "Alby Hub - Lightning Network node manager";
    homepage = "https://getalby.com";
    license = licenses.unfree; # Update this if you know the actual license
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ /* add yourself here */ ];
  };
}
