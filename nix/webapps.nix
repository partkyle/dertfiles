{ pkgs, lib }:

let
  # ── Your web apps: name → URL ──────────────────────────
  # Add/remove entries here and it'll work on next rebuild.
  apps = {
    Gemini = "https://gemini.google.com/app";
    Calendar = "https://calendar.google.com";
    GMail = "https://gmail.google.com";
  };

  sanitize = name:
    builtins.replaceStrings [ " " "." ] [ "-" "-" ] (lib.toLower name);

in {
  # Desktop entries → ~/.local/share/applications/*.desktop
  # Searchable by name (gmail, calendar, gemini) but NOT by "brave" —
  # the Exec field points at a wrapper script whose path has no "brave"
  # in it, so rofi drun's exec-field matching won't pollute results.
  desktopEntries = builtins.listToAttrs (map (name:
    let sanitized = sanitize name;
    in {
      name = sanitized;
      value = {
        name = name;
        exec = "/home/partkyle/.config/webapps/webapp-${sanitized}";
        icon = "brave-browser";
        categories = [ "Network" ];
        terminal = false;
        startupNotify = true;
      };
    }
  ) (builtins.attrNames apps));

  # Wrapper scripts → ~/.config/webapps/webapp-<name>
  # Each resolves brave via PATH at launch time.
  wrapperFiles = builtins.listToAttrs (map (name:
    let
      url = apps.${name};
      sanitized = sanitize name;
    in {
      name = "webapps/webapp-${sanitized}";
      value = {
        text = ''
          #!/usr/bin/env bash
          exec brave --app=${url} "$@"
        '';
        executable = true;
      };
    }
  ) (builtins.attrNames apps));
}
