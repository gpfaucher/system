{ config, ... }:
{
  # Tell agenix which SSH key to use for decryption
  age.identityPaths = [
    "/home/gabriel/.ssh/id_ed25519"
  ];

  age.secrets.aws-credentials = {
    file = ./aws-credentials.age;
    owner = "gabriel";
    group = "users";
    mode = "0400";
    # Decrypt directly to ~/.aws/credentials
    path = "/home/gabriel/.aws/credentials";
  };
}
