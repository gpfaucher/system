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
        ms-python.debugpy

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

        # Infrastructure / Cloud
        hashicorp.terraform
        redhat.vscode-yaml

        # Note: install AWS Toolkit from marketplace (amazonwebservices.aws-toolkit-vscode)
        # vscode-fhs supports runtime marketplace installs
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

        # Format on save
        "editor.formatOnSave" = true;
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        "[python]"."editor.defaultFormatter" = "ms-python.python";
        "[terraform]"."editor.defaultFormatter" = "hashicorp.terraform";

        # File associations for AWS/cloud configs
        "files.associations" = {
          "*.tf" = "terraform";
          "*.tfvars" = "terraform";
          "*.yml" = "yaml";
          "*.yaml" = "yaml";
        };

        # YAML settings (CloudFormation, SAM, k8s manifests)
        "yaml.schemas" = {
          "https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json" = [
            "*.cf.yaml"
            "*.cf.yml"
            "template.yaml"
            "template.yml"
          ];
        };
        "yaml.customTags" = [
          "!Ref"
          "!Sub"
          "!GetAtt"
          "!FindInMap"
          "!ImportValue"
          "!Select"
          "!Split"
          "!Join"
          "!If"
          "!Not"
          "!Equals"
          "!Or"
          "!And"
          "!Condition"
        ];

        # Terraform
        "terraform.languageServer.enable" = true;
      };
    };
  };
}
