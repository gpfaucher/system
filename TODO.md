# TODO

- [ ] Organise repository:
  - [ ] Add a new `hosts` folder with configurations possible for multiple hosts. Add a local file per host with hardware settings.
  - [ ] Add a new `modules` folder with configurations that can be shared between hosts, e.g. services and system-wide settings and home-manager configuratios..
- [ ] Add development shells for different environments using `devenv`:
  - [ ] All shells should use the base `fish` shell as default shell.
  - [ ] Flutter mobile app development with Flutter, Dart and an Android Emulator
  - [ ] Golang development with the golang toolchain
  - [ ] Python development with different environments
  - [ ] C# development with tools like EF Core, different SDK versions
  - [ ] Next.js / Node.js development
- [ ] Finalise XOrg configuration
  - [ ] Set XMonad background color to `#F08F90` using `hsetroot`
  - [ ] Set SDDM background color to `#F08F90`
  - [ ] Fix power management with NVIDIA so that suspend and wakeup works.
- [ ] Configure Neovim
  - [ ] Consider separating the configuration into a separate flake and using it here.
  - [ ] Separate out different aspect of th configuration into modules:
    - [ ] A `keymaps.nix` with all the globally defined keymaps.
    - [ ] A `plugins` folder with a `default.nix` that imports all different plugin configuration (stored in separate files).
    - [ ] A `keymaps.nix` with all the globally defined keymaps.
  - [ ] Go through `none-ls` configuration and add all useful formatters (like `nix fmt`). Make sure they're installed with as packages.
  - [ ] Add keymaps for all different plugins like `Neotree`.
  - [ ] Tweak `nvim-cmp` settings. Adjust keymaps, sources and UI.
  - [ ] Consider setting up Lua bytecode compilation to speed up Neovim
  - [ ] Remove all unnecessary plugins.

- [x] Switch to unstable packages as the main `nixpkgs` version to start out.

# References

A nice example of structure a dotfiles/nixos flake:
  - https://github.com/Ahwxorg/nixos-config/blob/master/modules/home/default.nix

Very promising tool to setup development environments (with presets for e.g. Flutter / Android Emulators)
  - https://github.com/cachix/devenv/tree/main
