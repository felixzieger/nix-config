{ ... }: {
  # eternal terminal requires host config
  programs.ssh.extraConfig = ''
    Host blausieb.felixzieger.de
        Port 33111
        ForwardAgent yes
    
    Host schwalbe.felixzieger.de
        Port 33111
        ForwardAgen
    '';
}
