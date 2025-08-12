_: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set NIX_BUILD_SHELL "fish"

      # --- THEME COLORS (from your JS theme) ---
      set -g color_fg        BFBDB6
      set -g color_bg        0D1017
      set -g color_accent    E6B450
      set -g color_error     D95757
      set -g color_info      59C2FF
      set -g color_warn      FF8F40
      set -g color_git_clean 7FD962
      set -g color_git_dirty F26D78
      set -g color_cwd       39BAE6

      # For better background contrast in terminal
      set -g fish_color_normal        $color_fg
      set -g fish_color_command       $color_cwd
      set -g fish_color_error         $color_error
      set -g fish_color_param         $color_info
      set -g fish_color_quote         AAD94C
      set -g fish_color_redirection   $color_accent
      set -g fish_color_end           $color_warn
      set -g fish_color_comment       AC B6 BF
      set -g fish_color_operator      F29668
      set -g fish_color_escape        E6B673
      set -g fish_color_autosuggestion 6C7380
      set -g fish_color_cwd           $color_cwd
      set -g fish_color_user          $color_accent
      set -g fish_color_host          $color_info
      set -g fish_color_selection     --background=475266
      set -g fish_color_search_match  --background=409FFF

    '';

    functions = {
      _git_branch_name = ''
        echo (command git symbolic-ref HEAD 2>/dev/null | sed -e 's|^refs/heads/||')
      '';

      _is_git_dirty = ''
        set -l show_untracked (git config --bool bash.showUntrackedFiles)
        set untracked ""
        if [ "$theme_display_git_untracked" = 'no' -o "$show_untracked" = 'false' ]
          set untracked '--untracked-files=no'
        end
        echo (command git status -s --ignore-submodules=dirty $untracked 2>/dev/null)
      '';

      fish_prompt = ''
        set -l last_status $status
        set -l arrow_color (test $last_status -eq 0; and set_color -o $color_git_clean; or set_color -o $color_error)
        set -l cwd_color (set_color -o $color_cwd)
        set -l git_clean_color (set_color -o $color_git_clean)
        set -l git_dirty_color (set_color -o $color_git_dirty)
        set -l git_branch_color (set_color -o $color_accent)
        set -l normal (set_color normal)

        set -l cwd $cwd_color(basename (prompt_pwd))

        set git_info ""
        if [ (_git_branch_name) ]
          set -l git_branch $git_branch_color(_git_branch_name)
          set git_info "$git_clean_color git:($git_branch$git_clean_color)"
          if test -n "(_is_git_dirty)"
            set git_info "$git_info$git_dirty_color ✗"
          end
        end

        echo -n -s $arrow_color'➜ ' $cwd ' ' $git_info $normal ' '
      '';
    };
  };
}
