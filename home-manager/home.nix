# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    inputs.nixvim.homeManagerModules.nixvim
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "gabriel";
    homeDirectory = "/home/gabriel";
  };

  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 52.992752;
    longitude = 6.564228;
  };

  xsession.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
    config = ./config/xmonad.hs;
  };

  # Add stuff for your user as you see fit:
  programs.alacritty.enable = true;
  programs.rofi.enable = true;
  home.packages = with pkgs; [ google-chrome playerctl pulsemixer zoom-us lutris ];
    programs.nixvim = {
    enable = true;

    colorschemes.catppuccin.enable = true;
    plugins.lualine.enable = true;
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.git.userEmail = "gpfaucher@gmail.com";
  programs.git.userName = "Gabriel Faucher";
  programs.librewolf.enable = true;

services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
    fadeDelta = 5;
    opacityRule = [ 
      "100:name *= 'i3lock'"
      "99:fullscreen"
      "90:class_g = 'Alacritty' && focused"
      "65:class_g = 'Alacritty' && !focused"
    ];
      
    shadow = true;
    shadowOpacity = 0.75;
    settings = {
      xrender-sync-fence = true;
      mark-ovredir-focused = false;
      use-ewmh-active-win = true;

      unredir-if-possible = false;
      backend = "glx"; # try "glx" if xrender doesn't help
      vsync = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
