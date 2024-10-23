{ ... }: {
  # eternal terminal requires host config
    home.file.".ssh/config".text = ''
    Host blausieb
        HostName blausieb.felixzieger.de
        Port 33111
        ForwardAgent yes

    Host schwalbe
        HostName schwalbe.felixzieger.de
        Port 33111
        ForwardAgent yes

    Host sonnenhofserver
        HostName nextcloud.sonnenhof-zieger.de
        Port 33111
        ForwardAgent yes
    '';
}
