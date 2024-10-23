{ ... }: {
  # eternal terminal requires host config
  # https://mynixos.com/home-manager/option/programs.ssh.matchBlocks and
  # https://mynixos.com/home-manager/option/programs.ssh.extraConfig
  # didn't work, so I manage the file manually
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
