{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
    prettier = {
      enable = true;
      includes = [
        "*.md"
        "*.json"
        "*.yaml"
        "*.yml"
      ];
    };
    shfmt.enable = true;
  };
}
