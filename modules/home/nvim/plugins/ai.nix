_: {
  programs.nixvim = {
    plugins = {
      render-markdown.enable = true;
      codecompanion = {
        enable = true;
        settings = {
          adapters = {
            ollama = {
              __raw = ''
                function()
                  return require('codecompanion.adapters').extend('openai_compatible', {
                      env = {
                          url = "https://openrouter.ai/api",
                          api_key = "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",
                          chat_url = "/v1/chat/completions"
                      },
                      schema = {
                          model = {
                              default = 'openai/gpt-oss-20b:free',
                          },
                          num_ctx = {
                              default = 32768,
                          },
                      },
                  })
                end
              '';
            };
          };
          opts = {
            log_level = "TRACE";
            send_code = true;
            use_default_actions = true;
            use_default_prompts = true;
          };
          strategies = {
            agent = {
              adapter = "openai_compatible";
            };
            chat = {
              adapter = "openai_compatible";
            };
            inline = {
              adapter = "openai_compatible";
            };
          };
        };
      };
    };
    # keymaps = [
    #   {
    #     action = "<cmd>LazyGit <cr>";
    #     key = "<leader>g";
    #   }
    # ];
  };
}
