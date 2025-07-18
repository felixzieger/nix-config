_: {
  # eternal terminal requires host config
  # https://mynixos.com/home-manager/option/programs.ssh.matchBlocks and
  # https://mynixos.com/home-manager/option/programs.ssh.extraConfig
  # didn't work, so I manage the file manually
  home.file.".ssh/config".text = ''
    Host *
        StrictHostKeyChecking no
        ForwardAgent yes

    Host blausieb
        HostName blausieb.felixzieger.de
        Port 33111

    Host schwalbe
        HostName schwalbe.felixzieger.de
        Port 33111

    Host cameron
        HostName cameron.felixzieger.de
        Port 33112 # Same public IP as sonnenhof-server so we use another port

    Host sonnenhofserver
        HostName nextcloud.sonnenhof-zieger.de
        Port 33111

    Host hedwig
        HostName hedwig.felixzieger.de
        Port 33111
  '';
}
