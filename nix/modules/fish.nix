{
  config,
  pkgs,
  home-manager,
  environment,
  ...
}:
{
  home-manager.users.partkyle = {
    programs.fish = {
      enable = true;

      # Declarative aliases (substitutes traditional fish_aliases)
      shellAliases = {
        g = "git";
        gst = "git status";
        # update = "sudo nixos-rebuild switch";
      };

      # Fish functions
      functions = {
        rebuild = {
          description = "Rebuild NixOS system";
          body = ''
            cd ~/.dertfiles/nix; and sudo nixos-rebuild switch --flake .#${config.networking.hostName} $argv
          '';
        };
        fish_greeting = {
          body = "";
        };
      };

      # plugins = [
      #   { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      # ];
    };
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    fishPlugins.fzf-fish
    fishPlugins.pure
    fzf
  ];
}
