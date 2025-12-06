{...}: {
  # bluetuith config file
  xdg.configFile."bluetuith/bluetuith.conf".text = ''
    {
      "behavior": {
        "adapter_states": {
          "powered": true,
          "discoverable": false,
          "pairable": true
        }
      },
      "keybindings": {
        "NavigateUp": "k",
        "NavigateDown": "j",
        "NavigateRight": "l",
        "NavigateLeft": "h",
        "Quit": "q",
        "Menu": "m"
      }
    }
  '';
}
