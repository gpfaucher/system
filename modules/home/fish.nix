_: {
  programs.starship.enable = true;
  programs.fish = {
    enable = true;
    shellAliases = {
      tree = "eza --icons --tree --group-directories-first";
      la = "eza -A --git";
      ll = "eza -l --git";
      lla = "eza -lA";
    };
    interactiveShellInit = ''
            set fish_greeting # Disable greeting
            set NIX_BUILD_SHELL "fish"

            # Auto-start hyprland on tty1
            if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
                exec hyprland
            end

            eval (ssh-agent -c)
            ssh-add ~/.ssh/ssh-pfx-github
            ssh-add
            clear

    '';
  };
}
