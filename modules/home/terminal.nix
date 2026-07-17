{ config, ... }:

{
  # Ghostty is installed through Homebrew; Home Manager and Stylix own its settings.
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      working-directory = config.home.homeDirectory;
      window-inherit-working-directory = false;
      window-padding-x = 4;
      window-padding-y = 4;
      copy-on-select = "clipboard";
      confirm-close-surface = false;
      mouse-hide-while-typing = true;
      scrollback-limit = 1000000000;

      # Make terminal Alt bindings reliable on every macOS keyboard layout.
      macos-option-as-alt = true;
      keybind = [
        # Fish/fzf expects ESC-c for its Alt-C directory picker.
        "alt+c=esc:c"
      ];
    };
  };
}
