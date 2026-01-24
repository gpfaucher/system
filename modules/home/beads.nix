{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.beads;
in
{
  options.programs.beads = {
    enable = mkEnableOption "Beads - Git-backed issue tracker for AI agents";

    package = mkOption {
      type = types.package;
      default = pkgs.beads;
      defaultText = literalExpression "pkgs.beads";
      description = "The beads package to use.";
    };

    enableDaemon = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable the beads background daemon for automatic git sync.
        The daemon monitors .beads/ directories and syncs changes.
      '';
    };

    shellIntegration = {
      enableFish = mkOption {
        type = types.bool;
        default = config.programs.fish.enable;
        defaultText = literalExpression "config.programs.fish.enable";
        description = "Enable Fish shell integration (completions and aliases).";
      };

      enableBash = mkOption {
        type = types.bool;
        default = config.programs.bash.enable;
        defaultText = literalExpression "config.programs.bash.enable";
        description = "Enable Bash shell integration (completions and aliases).";
      };

      enableZsh = mkOption {
        type = types.bool;
        default = config.programs.zsh.enable;
        defaultText = literalExpression "config.programs.zsh.enable";
        description = "Enable Zsh shell integration (completions and aliases).";
      };
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        bdr = "bd ready";
        bdc = "bd create";
        bds = "bd show";
        bdl = "bd list";
        bdd = "bd done";
      };
      description = ''
        Shell aliases for common beads commands.
        Set to {} to disable aliases.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install beads package
    home.packages = [ cfg.package ];



    # Fish shell integration
    programs.fish = mkIf cfg.shellIntegration.enableFish {
      # Add aliases
      shellAbbrs = cfg.aliases;

      # Helper function for quick beads status
      functions.bd-status = mkIf (cfg.aliases != {}) ''
        # Show ready tasks in current repo
        if test -d .beads
          echo "Ready tasks:"
          bd ready --format compact
        else
          echo "Not a beads repository. Run 'bd init' to initialize."
        end
      '';
    };

    # Bash shell integration
    programs.bash = mkIf cfg.shellIntegration.enableBash {
      shellAliases = cfg.aliases;
      
      initExtra = mkIf (cfg.aliases != {}) ''
        # Beads helper function for quick status
        bd-status() {
          if [ -d .beads ]; then
            echo "Ready tasks:"
            bd ready --format compact
          else
            echo "Not a beads repository. Run 'bd init' to initialize."
          fi
        }
      '';
    };

    # Zsh shell integration
    programs.zsh = mkIf cfg.shellIntegration.enableZsh {
      shellAliases = cfg.aliases;
      
      initExtra = mkIf (cfg.aliases != {}) ''
        # Beads helper function for quick status
        bd-status() {
          if [ -d .beads ]; then
            echo "Ready tasks:"
            bd ready --format compact
          else
            echo "Not a beads repository. Run 'bd init' to initialize."
          fi
        }
      '';
    };
  };
}
