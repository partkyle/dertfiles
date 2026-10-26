{
  lib,
  pkgs,
  config,
  ...
}:
let
  # REAPER's binaries are linked with `-z max-page-size=0x200000`. patchelf's
  # default 4 KiB page size rewrites their program headers into an overlapping
  # RW/RE LOAD pair (header LOAD at 0x3ff000 with size 0x3e58, code LOAD shifted
  # to file 0x1254 / vaddr 0x400254), so the loader maps the page holding
  # .dynamic read-only and the relocation write faults: `segfault at 402d50 …
  # error 7`, exit 139 on every start. Patching at the upstream 2 MiB page size
  # keeps the segments disjoint and the result loadable. auto-patchelf forwards
  # patchelfFlags to every patchelf call it makes.
  reaperPkg = pkgs.reaper.overrideAttrs (old: {
    patchelfFlags = [ "--page-size" "2097152" ];
    postInstall = (old.postInstall or "") + ''
      rm -rf $out/share/applications
    '';
  });
in
{
  options.programs.reaper = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to install REAPER and create a pw-jack desktop entry.";
    };
  };
  config = lib.mkIf config.programs.reaper.enable {
    home-manager.users.partkyle = {
      home.packages = [
        reaperPkg
        pkgs.pipewire.jack
      ];
      xdg.desktopEntries.reaper = {
        name = "REAPER (jack)";
        exec = "${pkgs.pipewire.jack}/bin/pw-jack ${reaperPkg}/bin/reaper";
        icon = "cockos-reaper";
        categories = [
          "Audio"
          "AudioVideo"
          "Sequencer"
        ];
        terminal = false;
        startupNotify = true;
      };
    };
  };
}
