{
  config,
  lib,
  pkgs,
  ...
}:

let
  localModel = "qwen3.6:latest";
  documentationModel = "qwen3.5:9b";
  documentationRoot = "${config.home.homeDirectory}/Developer/intern.wiki";
  documentationPrompt = pkgs.writeText "documentation-agent-prompt.md" ''
    You are the dedicated read-only documentation agent for the Markdown wiki in
    ${documentationRoot}.

    Answer questions using the wiki as the primary and authoritative source.

    Rules:
    - Search the wiki before answering, even when you think you know the answer.
    - Read the relevant Markdown files rather than relying on filenames alone.
    - Match the language of the user's question. Most wiki content is Dutch.
    - Cite every substantive answer with repository-relative Markdown paths and,
      where possible, a line number using the clickable form path/to/file.md:line.
    - Clearly distinguish documented facts from your own inference.
    - If the documentation is missing, contradictory, or possibly outdated, say so.
    - Never claim that an external system's current state matches the documentation.
    - Do not modify, create, delete, or move files. You are strictly read-only.
    - Prefer concise answers, followed by a short "Sources" list.

    When searching, try related Dutch and English terminology, synonyms, filenames,
    headings, and repository-wide content searches before concluding that an answer
    is absent.
  '';
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
          contextWindow = 98304;
          maxTokens = 8192;
          cost = {
            input = 0;
            output = 0;
            cacheRead = 0;
            cacheWrite = 0;
          };
        }
        {
          id = documentationModel;
          name = "Qwen3.5 9B (documentation)";
          reasoning = true;
          input = [
            "text"
            "image"
          ];
          contextWindow = 98304;
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
    enabledModels = [
      "ollama/${localModel}"
      "ollama/${documentationModel}"
    ];
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

  localDocsAgent = pkgs.writeShellApplication {
    name = "local-docs-agent";
    runtimeInputs = [ pkgs.pi-coding-agent ];
    text = ''
      cd ${lib.escapeShellArg documentationRoot}
      exec pi \
        --model ${lib.escapeShellArg "ollama/${documentationModel}"} \
        --tools read,grep,find,ls \
        --append-system-prompt ${lib.escapeShellArg documentationPrompt} \
        --session-id intern-wiki-documentation \
        --name "Documentation" \
        "$@"
    '';
  };

  openDoc = pkgs.writeShellApplication {
    name = "open-doc";
    runtimeInputs = with pkgs; [
      bat
      coreutils
      fd
      fzf
      neovim
    ];
    text = ''
      wiki_root=${lib.escapeShellArg documentationRoot}

      if [ "$#" -gt 1 ]; then
        echo "Usage: open-doc [relative/path.md[:line]]" >&2
        exit 2
      fi

      reference="''${1:-}"
      if [ -z "$reference" ]; then
        reference="$({
          cd "$wiki_root"
          fd --type f --extension md --hidden --exclude .git
        } | fzf \
          --prompt='Wiki file > ' \
          --preview="bat --color=always --style=numbers --line-range=:240 '$wiki_root'/{}")"
        [ -n "$reference" ] || exit 0
      fi

      line=1
      if [[ "$reference" =~ :([0-9]+)$ ]]; then
        line="''${BASH_REMATCH[1]}"
        reference="''${reference%:*}"
      fi

      reference="''${reference#./}"
      if [[ "$reference" = /* ]]; then
        target="$reference"
      else
        target="$wiki_root/$reference"
      fi

      target="$(realpath "$target")"
      case "$target" in
        "$wiki_root"/*.md) ;;
        *)
          echo "Refusing to open a path outside the Markdown wiki: $target" >&2
          exit 1
          ;;
      esac

      exec nvim "+$line" "$target"
    '';
  };

  askDocs = pkgs.writeShellApplication {
    name = "ask-docs";
    runtimeInputs = [
      herdrPackage
      pkgs.jq
    ];
    text = ''
      if [ "$#" -eq 0 ]; then
        echo 'Usage: ask-docs "your documentation question"' >&2
        exit 2
      fi

      if ! herdr status server >/dev/null 2>&1; then
        echo "Herdr is not running. Start Herdr, then run ask-docs again." >&2
        exit 1
      fi

      if ! herdr agent get docs >/dev/null 2>&1; then
        herdr agent start docs \
          --cwd ${lib.escapeShellArg documentationRoot} \
          --no-focus \
          -- ${localDocsAgent}/bin/local-docs-agent
        herdr agent wait docs --status idle --timeout 60000 >/dev/null
      fi

      pane_id="$(herdr agent get docs | jq -er '.result.agent.pane_id')"
      herdr agent send docs "$*" >/dev/null
      herdr pane send-keys "$pane_id" enter >/dev/null
      echo "Question sent to the docs agent. Open it with: herdr agent focus docs"
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
    localDocsAgent
    askDocs
    openDoc
  ];

  home.file.".pi/agent/models.json".source = piModels;
  home.file.".pi/agent/settings.json".source = piSettings;
  home.file.".pi/agent/extensions/.keep".text = "";
  home.file.".pi/agent/prompts/documentation-agent.md".source = documentationPrompt;

  home.sessionVariables = {
    PI_TELEMETRY = "0";
    PI_SKIP_VERSION_CHECK = "1";
  };

  xdg.configFile."herdr/config.toml".text = ''
    onboarding = false

    [ui]
    # Let Ghostty receive Cmd-clicks for URLs and file hyperlinks.
    mouse_capture = false

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
        OLLAMA_CONTEXT_LENGTH = "98304";
        OLLAMA_NUM_PARALLEL = "1";
        OLLAMA_FLASH_ATTENTION = "1";
        OLLAMA_KV_CACHE_TYPE = "q8_0";
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
