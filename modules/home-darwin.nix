{ pkgs, lib, ... }:
{
  home = {
    username = "gabriel";
    homeDirectory = "/Users/gabrielfaucher";
    stateVersion = "2305";
 
    # Enable Fish Shell for this user
    sessionPath = [ "$HOME/.local/bin" ];
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      ll = "ls -la";
    };
  };

  home.packages = with pkgs; [
    # Your standard CLI tools (these run natively on M4)
    git 
    neovim 
    ripgrep 
    fd 
    tmux 
    zoxide 
    bat 
    bottom 
  ];
  
  # Ensure Nix stuff is on path for user
  home.sessionVariables = {
    PATH = "$HOME/.nix-profile/bin:$PATH";
  };
}