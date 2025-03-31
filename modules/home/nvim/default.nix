{ inputs, ... }:
{
  imports = [ 
    inputs.nixvim.homeManagerModules.nixvim 
    ./core
    ./plugins
  ];

  programs.nixvim = {
    defaultEditor = true;
    enable = true;
    performance = {
      byteCompileLua = {
        enable = true;
        configs = true;
        initLua = true;
        nvimRuntime = true;
        plugins = true;
      };
    };
  };
}
