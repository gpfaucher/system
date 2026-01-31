let
  # SSH public key for encryption
  gabriel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE07KLDWLqBJHPYzj3sREYGu/22AEWv+J2EpX2i81bHh gabriel@nixos";
in
{
  "aws-credentials.age".publicKeys = [ gabriel ];
}
