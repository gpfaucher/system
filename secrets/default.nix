{ config, ... }:
{
  # Tell agenix which SSH key to use for decryption
  age.identityPaths = [
    "/home/gabriel/.ssh/id_ed25519"
  ];

  age.secrets.tabby-token = {
    file = ./tabby-token.age;
    owner = "gabriel";
    group = "users";
    mode = "0400";
  };
}
