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
        # Note: NixOS module generates a secret key if unset; override per-host if desired.
      };
    };
  };
}

