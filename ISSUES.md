# Known issues & quirks

## Dual foot systemd services

`programs.foot` (home-manager) creates `foot.service` which runs the foot
terminal server. The foot package also ships `foot-server.service` +
`foot-server.socket`, which get linked into the user systemd path
automatically. Both start a server — harmless but redundant.

To remove the package-provided ones, add to `nix/home.nix`:

```nix
programs.foot.package = pkgs.foot.overrideAttrs (old: {
  postInstall = (old.postInstall or "") + ''
    rm -rf $out/share/systemd
  '';
});
```
