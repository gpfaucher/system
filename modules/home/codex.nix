{ lib, ... }:
{
  # Install Codex configuration at ~/.codex/config.toml (TOML format)
  home.file.".codex/config.toml" = {
    source = ./assets/codex/config.toml;
  };

  # Optionally, you can set environment variables here via Home-Manager if desired, e.g.:
  # home.sessionVariables.CONTEXT7_TOKEN = ""; # leave unset; use a secret manager or set per-host.
}
