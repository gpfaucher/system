{ config, pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # Theme
        sainnhe.gruvbox-material

        # AI
        anthropic.claude-code

        # Nix
        jnoortheen.nix-ide

        # Python
        ms-python.python
        ms-python.vscode-pylance

        # JavaScript/TypeScript
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        bradlc.vscode-tailwindcss

        # Git
        eamodio.gitlens

        # Vim
        vscodevim.vim

        # Remote Development
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers
        ms-vscode.remote-explorer

        # Kubernetes & Containers
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
      ];

      userSettings = {
        # Theme (mkForce to override Stylix)
        "workbench.colorTheme" = lib.mkForce "Gruvbox Material Dark";
        "workbench.iconTheme" = lib.mkForce "gruvbox-material-icon-theme";

        # Font (mkForce to override Stylix)
        "editor.fontFamily" = lib.mkForce "'Monaspace Neon', 'Symbols Nerd Font', monospace";
        "editor.fontSize" = lib.mkForce 14;
        "editor.fontLigatures" = true;
        "terminal.integrated.fontFamily" = lib.mkForce "'Monaspace Neon', monospace";
        "terminal.integrated.fontSize" = lib.mkForce 14;

        # Editor
        "editor.minimap.enabled" = false;
        "breadcrumbs.enabled" = false;
        "workbench.activityBar.location" = "hidden";
        "editor.padding.top" = 8;
        "editor.smoothScrolling" = true;
        "editor.cursorBlinking" = "smooth";
        "editor.cursorSmoothCaretAnimation" = "on";

        # Window
        "window.titleBarStyle" = "native";

        # Telemetry
        "telemetry.telemetryLevel" = "off";

        # Nix IDE
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
      };
    };
  };
}
