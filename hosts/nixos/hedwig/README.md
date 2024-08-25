Hedwig is an IONOS VPS.

I chose Ubuntu 22.04 as base image and then did

```
ssh-copy-id root@xxx.xxx.xxx.xxx
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-24.05 bash -x
wait for reboot
```
