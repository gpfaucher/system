{ pkgs, ... }:
{
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    settings = {
      server = {
        bind_address = "127.0.0.1";
        port = 8080;
        base_url = "http://localhost:8080/";
        secret_key = "bd4e0c4a2f3b4a598a7c9d0e1f2a3b4c";
        # Note: NixOS module generates a secret key if unset; override per-host if desired.
      };
    };
  };
}
