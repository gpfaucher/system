{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./core
    ./plugins
  ];

  programs.nixvim = {
    nixpkgs.pkgs = pkgs;
    defaultEditor = true;
    enable = true;
    performance = {
      combinePlugins.enable = true;
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        luaLib = true;
        nvimRuntime = true;
        plugins = true;
      };
    };
  };
}
