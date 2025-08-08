{ lib, host, ... }:
{
  programs.zsh = {
    enable = true;
    promptInit = ''prompt_context(){}'';
    shellInit = ''
      eval "$(direnv hook zsh)"
      if [[ -z $DISPLAY && $XDG_VTNR == 1 ]]; then
        ${lib.mkIf (host == "voyager") ''
          export WLR_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
        ''}
        exec sway
      fi
    '';
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "z" "autojump" ];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
