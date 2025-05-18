{ pkgs, ... }: {
  services.greetd = {
    enable = true;
    # vt = 3;
    settings = {
      # default_session = {
        # command = "${pkgs.greetd.greetd}/bin/greetd"; # start Hyprland with a TUI login manager
      # };
    };
  };
}
