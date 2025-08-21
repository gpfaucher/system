_: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set NIX_BUILD_SHELL "fish"

      set -g fish_color_normal f2f4f8
      set -g fish_color_command 42be65
      set -g fish_color_keyword be95ff
      set -g fish_color_error ee5396
      set -g fish_color_param 3ddbd9
      set -g fish_color_string 33b1ff
      set -g fish_color_quote 33b1ff
      set -g fish_color_redirection 78a9ff
      set -g fish_color_comment 6f6f6f
      set -g fish_color_operator be95ff
      set -g fish_color_end be95ff
      set -g fish_color_autosuggestion 525252
      set -g fish_color_history_current --bold
      set -g fish_color_search_match --background=33b1ff40
      set -g fish_color_selection --background=30293a

      # Pager (Tab Completion Menu) Colors
      set -g fish_pager_color_prefix 78a9ff
      set -g fish_pager_color_completion f2f4f8
      set -g fish_pager_color_description 6f6f6f
      set -g fish_pager_color_selected_background --background=262626
      set -g fish_pager_color_progress 3ddbd9
    '';
  };
}
