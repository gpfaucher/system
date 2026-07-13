{
  config,
  lib,
  pkgs,
  ...
}:

let
  localModel = "qwen3.6:latest";
  herdrPackage = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr";
    version = "0.7.3";
    src = pkgs.fetchurl {
      url = "https://github.com/ogulcancelik/herdr/releases/download/v0.7.3/herdr-macos-aarch64";
      hash = "sha256-sxNFOS0ATsHxssgh4a1gEBn6g4X+HkxpMTIetYqSB3M=";
    };
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/herdr"
      runHook postInstall
    '';
  };

  piModels = (pkgs.formats.json { }).generate "pi-models.json" {
    providers.ollama = {
      baseUrl = "http://127.0.0.1:11434/v1";
      api = "openai-completions";
      apiKey = "ollama";
      compat = {
        supportsDeveloperRole = false;
        supportsReasoningEffort = false;
      };
      models = [
        {
          id = localModel;
          name = "Qwen3.6 (local)";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 32768;
          maxTokens = 8192;
          cost = {
            input = 0;
            output = 0;
            cacheRead = 0;
            cacheWrite = 0;
          };
        }
      ];
    };
  };

  piSettings = (pkgs.formats.json { }).generate "pi-settings.json" {
    defaultProvider = "ollama";
    defaultModel = localModel;
    defaultThinkingLevel = "low";
    hideThinkingBlock = false;
    theme = "dark";
    defaultProjectTrust = "ask";
    enableInstallTelemetry = false;
    enabledModels = [ "ollama/${localModel}" ];
    packages = [ ];
    compaction = {
      enabled = true;
      reserveTokens = 8192;
      keepRecentTokens = 12000;
    };
    retry = {
      enabled = true;
      maxRetries = 2;
      baseDelayMs = 2000;
    };
    terminal.showImages = true;
  };

  mkPiWrapper =
    {
      name,
      readOnly ? false,
    }:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.pi-coding-agent ];
      text = ''
        exec pi --model ${lib.escapeShellArg "ollama/${localModel}"} ${lib.optionalString readOnly "--tools read,grep,find,ls"} "$@"
      '';
    };
in
{
  home.packages = [
    herdrPackage
    pkgs.ollama
    pkgs.pi-coding-agent
    (mkPiWrapper { name = "local-agent"; })
    (mkPiWrapper {
      name = "local-agent-readonly";
      readOnly = true;
    })
  ];

  home.file.".pi/agent/models.json".source = piModels;
  home.file.".pi/agent/settings.json".source = piSettings;
  home.file.".pi/agent/extensions/.keep".text = "";

  home.sessionVariables = {
    PI_TELEMETRY = "0";
    PI_SKIP_VERSION_CHECK = "1";
  };

  xdg.configFile."herdr/config.toml".text = ''
    onboarding = false

    [session]
    resume_agents_on_restore = true

    [worktrees]
    directory = "~/.local/share/herdr/worktrees"
  '';

  launchd.agents.ollama = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.ollama}/bin/ollama"
        "serve"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Background";
      EnvironmentVariables = {
        OLLAMA_HOST = "127.0.0.1:11434";
        OLLAMA_CONTEXT_LENGTH = "32768";
        OLLAMA_NUM_PARALLEL = "2";
        OLLAMA_MAX_LOADED_MODELS = "1";
      };
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ollama.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ollama-error.log";
    };
  };

  home.activation.installHerdrPiIntegration = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD ${herdrPackage}/bin/herdr integration install pi
  '';
}
