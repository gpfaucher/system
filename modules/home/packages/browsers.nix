{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    (google-chrome.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--enable-features=WebRTCPipeWireCapturer"
      ];
    })
    (chromium.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        "--enable-features=WebRTCPipeWireCapturer"
      ];
    })
  ];
}
