_: {
  programs.nixvim.plugins = {
    schemastore = {
      enable = true;
      yaml.enable = true;
      json.enable = false;
    };

    lint = {
      enable = true;
      lintersByFt = {
        text = ["vale"];
        json = ["jsonlint"];
        markdown = ["vale"];
        rst = ["vale"];
        ruby = ["ruby"];
        janet = ["janet"];
        inko = ["inko"];
        clojure = ["clj-kondo"];
        dockerfile = ["hadolint"];
        terraform = ["tflint"];
      };
    };

    lsp-format.enable = true;
  };
}
