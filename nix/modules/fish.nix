{ pkgs, home-manager, environment, ... }: {
  home-manager.users.partkyle = {
    programs.fish = {
      enable = true;

      # Declarative aliases (substitutes traditional fish_aliases)
      shellAliases = {
        g = "git";
        # update = "sudo nixos-rebuild switch";
      };

      # Inject initialization scripts (e.g., Starship prompt)
      interactiveShellInit = ''
        set -g fish_greeting ""
      '';

      # plugins = [
      #   { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      # ];
    };
  };

  environment.systemPackages = with pkgs; [
    fishPlugins.fzf-fish
    fzf
  ];
}

