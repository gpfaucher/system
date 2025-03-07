{ ... }: {
  imports =
       [(import ./git.nix)]
    ++ [(import ./nvim.nix)]
    ++ [(import ./zathura.nix)]
    ++ [(import ./packages.nix)]
    ++ [(import ./fish.nix)]
    ++ [(import ./tmux.nix)]
    ++ [(import ./terminal.nix)]
    ++ [(import ./xmonad)];
}
