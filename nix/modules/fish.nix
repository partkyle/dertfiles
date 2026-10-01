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
        fish_greeting = {
          body = "";
        };

        # dert emits its completion candidates from its own command
        # registries (`dert __complete`), so this helper never goes stale.
        __dert_complete = {
          body = ''
            set -l tokens (commandline -opc)
            set -e tokens[1]
            command dert __complete $tokens
          '';
        };
      };

      # Infinite shell history — no size or age limits
      interactiveShellInit = ''
        set -U fish_max_history_file_size 0
        set -U fish_max_history_age 0
        complete -c dert -f -a '(__dert_complete)'
      '';

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
