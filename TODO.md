# TODO

## Networking switch: systemd-networkd + iwd

Rebuild both hosts:

```bash
cd ~/.dertfiles/nix
sudo nixos-rebuild switch --flake .#dionysus
sudo nixos-rebuild switch --flake .#theseus
```

### On dionysus after reboot — connect to WiFi

```bash
iwctl
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect "SSID"
```

Profiles are saved automatically in `/var/lib/iwd/` — reconnects on future boots.
