{ ... }: {
  imports =
    [ (import ./git.nix) ]
    ++ [ (import ./zathura.nix) ]
    ++ [ (import ./packages.nix) ]
    ++ [ (import ./zsh.nix) ]
    ++ [ (import ./tmux.nix) ]
    ++ [ (import ./terminal.nix) ]
    ++ [ (import ./nvim) ]
    ++ [ (import ./scripts) ]
    ++ [ (import ./wayland.nix) ];
}
