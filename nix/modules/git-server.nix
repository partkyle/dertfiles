{ pkgs, config, ... }:
{
  users.groups.git = {};

  users.users.git = {
    isNormalUser = true;
    group = "git";
    home = "/srv/git";
    shell = "${pkgs.git}/bin/git-shell";
    openssh.authorizedKeys.keys = config.users.users.partkyle.openssh.authorizedKeys.keys;
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "create-repo" ''
      #!/usr/bin/env bash
      set -e
      REPO_NAME="$1"
      REPO_PATH="/srv/git/$REPO_NAME.git"

      if [ -z "$REPO_NAME" ]; then
        echo "Usage: create-repo <name>"
        exit 1
      fi

      if [[ ! "$REPO_NAME" =~ ^[a-zA-Z0-9._/-]+$ ]] || [[ "$REPO_NAME" =~ \.\. ]]; then
        echo "Error: repo name must be alphanumeric path (a-z, 0-9, ., _, -, /), no .."
        exit 1
      fi

      if [ -d "$REPO_PATH" ]; then
        echo "Error: $REPO_PATH already exists"
        exit 1
      fi

      if [ "$EUID" -ne 0 ]; then
        echo "Error: must be run as root (use sudo)"
        exit 1
      fi

      mkdir -p "$REPO_PATH"
      chown git:git "$REPO_PATH"
      su -s /bin/sh git -c "${pkgs.git}/bin/git init --bare --initial-branch=main '$REPO_PATH'"
      echo "Created bare repo: $REPO_PATH"
    '')
  ];
}
