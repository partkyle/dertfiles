{ pkgs, lib }:

let
  # ── Your web apps: name → URL ──────────────────────────
  # Add/remove entries here and it'll work on next rebuild.
  apps = {
    Gemini = "https://gemini.google.com/app";
    Calendar = "https://calendar.google.com";
    GMail = "https://gmail.google.com";
  };

in
builtins.listToAttrs (map (name:
  let
    url = apps.${name};
    sanitized = builtins.replaceStrings [ " " "." ] [ "-" "-" ] (lib.toLower name);
  in {
    name = sanitized;
    value = {
      name = name;
      exec = "${pkgs.brave}/bin/brave --app=${url}";
      categories = [ "Network" ];
      terminal = false;
      startupNotify = true;
    };
  }
) (builtins.attrNames apps))
