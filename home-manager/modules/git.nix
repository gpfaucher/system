{ config, ... }:
{
  programs.git = {
    enable = true;
    userEmail = "gpfaucher@gmail.com";
    userName = "Gabriel Faucher";
  };
}
