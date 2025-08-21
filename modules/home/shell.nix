{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Disable the default greeting message.
      set fish_greeting

      # Set NIX_BUILD_SHELL to fish.
      set NIX_BUILD_SHELL "fish"

      # Oxocarbon Fish Theme (for syntax highlighting, etc.)
      set -g fish_color_normal f2f4f8
      set -g fish_color_command 42be65
      set -g fish_color_keyword be95ff
      set -g fish_color_error ee5396
      set -g fish_color_param 3ddbd9
      set -g fish_color_string 33b1ff
      set -g fish_color_quote 33b1ff
      set -g fish_color_redirection 78a9ff
      set -g fish_color_comment 525252
      set -g fish_color_operator be95ff
      set -g fish_color_end be95ff
      set -g fish_color_autosuggestion 525252
      set -g fish_color_history_current --bold
      set -g fish_color_search_match --background=33b1ff40
      set -g fish_color_selection --background=262626

      # Pager (Tab Completion Menu) Colors
      set -g fish_pager_color_prefix 78a9ff
      set -g fish_pager_color_completion f2f4f8
      set -g fish_pager_color_description 525252
      set -g fish_pager_color_selected_background --background=262626
      set -g fish_pager_color_progress 3ddbd9

      # Initialize Starship prompt.
      starship init fish | source
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      # By concatenating the strings, we create a single line for the format
      # variable, avoiding any issues with backslashes and newlines.
      format =
        "$username" +
        "$hostname" +
        "$directory" +
        "$git_branch" +
        "$git_state" +
        "$git_status" +
        "$cmd_duration" +
        "$line_break" +
        "$python" +
        "$character";

      directory = {
        style = "blue";
      };

      character = {
        success_symbol = "[⟶](purple)";
        error_symbol = "[⟶](red)";
        vimcmd_symbol = "[⟵](green)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "bright-black";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        # Using a multi-line string here is fine because it doesn't have trailing backslashes.
        format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
        style = "bright-black";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "yellow";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };
    };
  };
}
