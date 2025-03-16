{ ... }: {
  imports =
    [ (import ./git.nix) ]
    ++ [ (import ./zathura.nix) ]
    ++ [ (import ./packages.nix) ]
    ++ [ (import ./fish.nix) ]
    ++ [ (import ./tmux.nix) ]
    ++ [ (import ./terminal.nix) ]
    ++ [ (import ./nvim) ]
    ++ [ (import ./wayland.nix) ];
}
