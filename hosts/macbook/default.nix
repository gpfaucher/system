{ username, ... }:

{
  imports = [
    ../../modules/darwin
  ];

  system.stateVersion = 7;
  system.primaryUser = username;
}
